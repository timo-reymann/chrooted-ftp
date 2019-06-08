FROM alpine:3.9.4

ENV UMASK 022
ENV PASSIVE_MIN_PORT 10090
ENV PASSIVE_MAX_PORT 10100
ENV BANNER "Welcome to chrooted-ftp!"

EXPOSE 21
EXPOSE 10090-10100

RUN apk add --no-cache vsftpd

COPY seed-config.sh entrypoint.sh /
COPY defaults/users /opt/chrooted-ftp/users

RUN sh seed-config.sh

ENTRYPOINT /entrypoint.sh
