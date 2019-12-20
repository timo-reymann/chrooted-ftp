FROM alpine:3.11.0

ENV UMASK 022
ENV PASSIVE_MIN_PORT 10090
ENV PASSIVE_MAX_PORT 10100
ENV BANNER "Welcome to chrooted-ftp!"
ENV PUBLIC_HOST "localhost"

EXPOSE 21
EXPOSE 10090-10100

RUN apk add --no-cache vsftpd

COPY scripts/seed-config.sh scripts/entrypoint.sh /
COPY defaults/users /opt/chrooted-ftp/users

RUN chmod +x seed-config.sh && chmod +x /entrypoint.sh

ENTRYPOINT /entrypoint.sh
