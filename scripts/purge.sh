#!/bin/sh

BINS_TO_KEEP=" echo cat grep rm busybox ls mkdir sed mv ssh-keygen sh date tty chown passwd false cut tini "
SBINS_TO_KEEP=" adduser sshd vsftpd tini "

for f in $(ls /bin /usr/bin)
do
    if [[  "${BINS_TO_KEEP}" != *" $f "* ]];
    then
        echo "Remove bin: $f"
        rm /bin/$f || rm /usr/bin/$f
    fi
done

for f in $(ls /sbin /usr/sbin)
do
    if [[ "${SBINS_TO_KEEP}" != *" $f "* ]];
    then
        echo "> Remove sbin: $f"
        rm /sbin/$f || rm /usr/sbin/$f
    fi
done
