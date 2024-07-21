#!/bin/ash
ROOT_FOLDER="/opt/chrooted-ftp"
DATA_FOLDER="/data"
if [ -n "${NO_USER_FTP_POSTFIX}" ]
then
    USER_FTP_POSTFIX=
fi

log() {
    local component="$1"
    local message="$2"
    echo -e "[\033[1;36m$(printf '%-7s' "${component}")\033[0m] \033[1;35m$(date +'%Y-%m-%dT%H:%M:%S')\033[0m ${message}"
}

# Check if the given user exists
user_exists() {
  cat /etc/passwd | grep "$1" >/dev/null 2>&1

  if [ $? -eq 0 ] ; then
    echo 1
  else
    echo 0
  fi
}

# Create user and setup directory structure
create_user() {
    local username="$1"
    local password="$2"

    if [ $(user_exists $username) -eq 1 ];
    then
        log "GENERAL" "User ${username} already exists, skip creation"
    else
      log "GENERAL" "Creating user ${username}"
      adduser -S -h "${DATA_FOLDER}/$username" -g "$username" -s /bin/false -D "$username"
      echo -e "${password}\n${password}" | passwd "$username" &> /dev/null

      log "SFTP" "Prepare file structure for ${username}"
      chown root:root "${DATA_FOLDER}/$username"
      mkdir -p "${DATA_FOLDER}/$username${USER_FTP_POSTFIX}"
      chown $username "${DATA_FOLDER}/$username${USER_FTP_POSTFIX}"
    fi
}

# Read line by line from users file
create_users_from_config() {
  while IFS= read -r line
  do
    if [ -z $line ];
    then
      continue;
    fi

    create_user "$(echo "$line" | cut -d ':' -f1)" "$(echo "$line" | cut -d ':' -f2)"
  done < "$ROOT_FOLDER/users"
}

# Create users from env vars
create_users_from_env() {
  local users="$(env | grep ACCOUNT_)"
  for user_spec in $users; do
    local username="$(echo "$user_spec" | cut -d '=' -f1 | cut -d '_' -f2)"
    local password="$(echo "$user_spec" | cut -d '=' -f2)"
    
    create_user "${username}" "${password}"
  done
}

# Create root data folder
create_data_folder() {
    log "GENERAL" "Make sure data folder exists and is owned by root"
    mkdir -p "${DATA_FOLDER}"
    chown root:root "${DATA_FOLDER}"
}

# Configure VSFTPD
configure_vsftpd() {
    VSFTPD_CONFIG_FILE=/etc/vsftpd/vsftpd.conf

    log "FTP" "Append custom config to vsftpd config"
    cat <<EOF >> $VSFTPD_CONFIG_FILE
# chroot
allow_writeable_chroot=YES
chroot_local_user=YES
passwd_chroot_enable=YES
local_enable=YES
local_root=${DATA_FOLDER}/\$USER${USER_FTP_POSTFIX}
local_umask=${UMASK}
user_sub_token=\$USER

# general
ftpd_banner=${BANNER}
listen_ipv6=NO
write_enable=YES
seccomp_sandbox=NO
vsftpd_log_file=$(tty)

# passive mode
pasv_enable=${PASSIVE_MODE_ENABLED:-'yes'}
pasv_max_port=${PASSIVE_MAX_PORT}
pasv_min_port=${PASSIVE_MIN_PORT}
pasv_addr_resolve=NO
pasv_promiscuous=${PASSIVE_PROMISCUOUS}
pasv_address=${PUBLIC_HOST}

# active mode
connect_from_port_20=${ACTIVE_MODE_ENABLED:-'yes'}
EOF

    log "FTP" "Disable anonymous login"
    sed -i "s/anonymous_enable=YES/anonymous_enable=NO/" "$VSFTPD_CONFIG_FILE"

    log "FTP" "Remove suffixed whitespace from config"
    sed -i 's,\r,,;s, *$,,' "$VSFTPD_CONFIG_FILE"
}

# Configure sshd for sftp
configure_sftp() {
    log "SFTP" "Check for existing host keys or create a new pair"
    if [ ! -d "${ROOT_FOLDER}/ssh_hostkeys" ]
    then
        mkdir -p "${ROOT_FOLDER}/ssh_hostkeys"
        log "SFTP" "Create host keys"
        ssh-keygen -A >/dev/null
        mv /etc/ssh/ssh_host_* "${ROOT_FOLDER}/ssh_hostkeys/"
    fi

    log "SFTP" "Create banner file"
    echo "${BANNER}" > /etc/ssh/banner

    log "SFTP" "Configure OpenSSH-Server"
    cat << EOF > /etc/ssh/sshd_config
AllowTcpForwarding      no
Banner                  /etc/ssh/banner
ForceCommand            internal-sftp
ChrootDirectory         ${DATA_FOLDER}/%u
GatewayPorts            no
HostbasedAuthentication no
HostKey                 /opt/chrooted-ftp/ssh_hostkeys/ssh_host_dsa_key
HostKey                 /opt/chrooted-ftp/ssh_hostkeys/ssh_host_ecdsa_key
HostKey                 /opt/chrooted-ftp/ssh_hostkeys/ssh_host_ed25519_key
HostKey                 /opt/chrooted-ftp/ssh_hostkeys/ssh_host_rsa_key
IgnoreUserKnownHosts    yes
LogLevel                INFO
PasswordAuthentication  yes
PermitEmptyPasswords    no
PermitTTY               no
PermitTunnel            no
Port                    2022
PubkeyAuthentication    no
Subsystem               sftp    /usr/lib/ssh/internal-sftp r -d /data
UseDNS                  no
X11Forwarding           no
EOF

}

create_data_folder
create_users_from_config
create_users_from_env
configure_vsftpd
configure_sftp

log "GENERAL" "Setup completed."
log "VSFTPD" "Starting"
log "SFTP" "Starting"

exec multirun "/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf" "/usr/sbin/sshd -D -e"
