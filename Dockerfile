FROM alpine:3.18.3 as base_system
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
