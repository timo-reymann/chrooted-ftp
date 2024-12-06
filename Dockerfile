FROM alpine:3.21.0 AS base_system

# Install packages
# renovate: datasource=repology depName=alpine_3_20/openssh versioning=loose
ARG openssh_version=9.7_p1-r4

# renovate: datasource=repology depName=alpine_3_20/vsftpd versioning=loose
ARG vsftpd_version=3.0.5-r2

RUN apk add --no-cache \
    vsftpd=${vsftpd_version} \
    openssh=${openssh_version} \
    multirun \
    && apk del --no-cache ca-certificates alpine-keys linux-pam \
    && rm -rf \
        /var/cache/apk \
        /var/log \
        /var/mail \
        /var/run \
        /var/spool \
        /usr/share/man \
        /etc/apk \
        /etc/crontabs \
        /etc/logrotate.d \
        /lib/apk \
        /sbin/apk \
        /media \
        /mnt \
        /sbin/ldconfig \
        /home \
        /usr/bin/ssh-keyscan \
        /usr/bin/ssh-copy-id \
        /usr/bin/ssh-agent

# Copy over utils
COPY scripts/entrypoint.sh ./entrypoint
COPY ./defaults/users ./opt/chrooted-ftp/users

FROM scratch
LABEL org.opencontainers.image.title="chrooted-ftp"
LABEL org.opencontainers.image.description="A dead simple alpine-based docker container to allow users only access their own home directory."
LABEL org.opencontainers.image.ref.name="main"
LABEL org.opencontainers.image.licenses='"Climate Strike" License Version 1.0 (Draft)'
LABEL org.opencontainers.image.vendor="Timo Reymann <mail@timo-reymann.de>"
LABEL org.opencontainers.image.authors="Timo Reymann <mail@timo-reymann.de>"
LABEL org.opencontainers.image.url="https://github.com/timo-reymann/chrooted-ftp"
LABEL org.opencontainers.image.documentation="https://github.com/timo-reymann/chrooted-ftp"
LABEL org.opencontainers.image.source="https://github.com/timo-reymann/chrooted-ftp.git"

COPY --from=base_system / /

ENV UMASK=022
ENV ACTIVE_MODE_ENABLED="yes"
ENV PASSIVE_MODE_ENABLED="yes"
ENV PASSIVE_PROMISCUOUS="no"
ENV PASSIVE_MIN_PORT=10090
ENV PASSIVE_MAX_PORT=10100
ENV PUBLIC_HOST="127.0.0.1"
ENV BANNER="Welcome to chrooted-ftp!"
ENV USER_FTP_POSTFIX=/data
ENV NO_USER_FTP_POSTFIX=""

EXPOSE 21
EXPOSE 10090-10100
EXPOSE 2022

VOLUME [ "/opt/chrooted-ftp" ]

ENTRYPOINT ["/entrypoint"]
