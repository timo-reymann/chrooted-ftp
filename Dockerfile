FROM alpine:3.19.0 as base_system
# Install packages
RUN apk add --no-cache \
    vsftpd \
    openssh \
    tini && \
    rm -rf /etc/apk

# Copy over utils
COPY scripts/entrypoint.sh ./entrypoint
COPY scripts/purge.sh /purge-bins
COPY ./defaults/users ./opt/chrooted-ftp/users

RUN /purge-bins && \
    rm -rf /*/apk && \
    rm /lib/libapk* && \
    rm -rf /media /mnt

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

ENV UMASK 022
ENV PASSIVE_MIN_PORT 10090
ENV PASSIVE_MAX_PORT 10100
ENV PUBLIC_HOST "localhost"
ENV BANNER "Welcome to chrooted-ftp!"
ENV USER_FTP_POSTFIX=/data
ENV NO_USER_FTP_POSTFIX=

EXPOSE 21
EXPOSE 10090-10100
EXPOSE 2022

VOLUME [ "/opt/chrooted-ftp" ]

ENTRYPOINT ["tini", "--", "/entrypoint"]
