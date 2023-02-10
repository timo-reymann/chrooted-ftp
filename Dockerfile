FROM busybox as base
WORKDIR /fs-root

COPY scripts/entrypoint.sh ./entrypoint
COPY ./defaults/users ./opt/chrooted-ftp/users
RUN chmod +x ./entrypoint

FROM alpine:3.17.2 as container
ENV UMASK 022
ENV PASSIVE_MIN_PORT 10090
ENV PASSIVE_MAX_PORT 10100
ENV PUBLIC_HOST "localhost"

ENV BANNER "Welcome to chrooted-ftp!"

EXPOSE 21
EXPOSE 10090-10100
EXPOSE 2022

VOLUME [ "/opt/chrooted-ftp" ]

RUN apk add --no-cache \
    vsftpd \
    openssh \
    tini

COPY --from=base /fs-root /

ENTRYPOINT ["tini", "--", "/entrypoint"]
