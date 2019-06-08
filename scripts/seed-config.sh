#!/bin/sh

CONFIG_FILE=/etc/vsftpd/vsftpd.conf

VSFTPD_CONFIG="$(cat <<EOF
local_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
write_enable=YES
local_umask=${UMASK}
passwd_chroot_enable=yes
pasv_enable=Yes
pasv_max_port=${PASSIVE_MAX_PORT}
pasv_min_port=${PASSIVE_MIN_PORT}
pasv_addr_resolve=NO
listen_ipv6=NO
seccomp_sandbox=NO
ftpd_banner=${BANNER}
EOF
)"

echo ""
printf "Append custom config to vsftpd config ... "
echo "$VSFTPD_CONFIG" >> $CONFIG_FILE
echo "Done."

printf "Disable anonymous login ... "
sed -i "s/anonymous_enable=YES/anonymous_enable=NO/" $CONFIG_FILE
echo "Done."

printf "Remove suffixed whitespace from config ..."
sed -i 's,\r,,;s, *$,,' $CONFIG_FILE
echo "Done."

echo ""
