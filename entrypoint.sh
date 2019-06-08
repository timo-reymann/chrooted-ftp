#!/bin/sh
ROOT_FOLDER=/opt/chrooted-ftp

user_exists() {
  cat /etc/passwd | grep $1 >/dev/null 2>&1

  if [ $? -eq 0 ] ; then
    echo 1
  else
    echo 0
  fi
}

mkdir -p /data

# Read line by line from users file
while IFS= read -r line
do
  if [ -z $line ];
  then
    continue;
  fi

  username=$(echo $line | cut -d ':' -f1)
  password=$(echo $line | cut -d ':' -f2)

  if [ $(user_exists $username) -eq 1 ];
  then
    echo "User ${username} already exists, skip creation ..."
  else
    echo "Creating user ${username} ..."
    adduser -S -h /data/$username -s /bin/false -D $username
    echo -e "${password}\n${password}" | passwd $username &> /dev/null
  fi
done < $ROOT_FOLDER/users

echo "Starting vsftpd"
# Start vsftpd with the configuration
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf