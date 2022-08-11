chrooted-ftp
====
[![GitHub Release](https://img.shields.io/github/v/tag/timo-reymann/chrooted-ftp.svg?label=version)](https://github.com/timo-reymann/chrooted-ftp/releases)
[![DockerHub](https://img.shields.io/docker/pulls/timoreymann/chrooted-ftp)](https://hub.docker.com/r/timoreymann/chrooted-ftp)
[![Dependabot](https://badgen.net/badge/Dependabot/enabled/green?icon=dependabot)](https://dependabot.com/)

A dead simple alpine-based docker container to allow users only access their own home directory.

## Why?!

The problem this container is solving is the following:
I want to provide ftp for some users, but i dont want to configure the chroot stuff and so on.
So this container is doing exactly that. You can mount `/data` as your volume the subfolders are per user.
So you can mount for example a website for a user under `/data/bob` and your host volume
is `/var/www/bobs.homepage.digital`. Its just that simple.

## Okay so how do i use this

### Prepare

1. Add user entry in form username:password into a file mounted under `/opt/chrooted-ftp/users`.
2. Mount the desired host volume under `/data/username`
3. Fire up the server.

### Usage with FTP

1. Expose port `21` (also see the sample docker-compose)
2. Your user can connect to the ftp server, only seeing their files

### Usage with SFTP

1. Expose port `2022` (also see the sample docker-compose)
2. If you want to keep the host keys across restarts make sure to mount `/opt/chrooted-ftp/ssh_hostkeys`
3. Your user can connect to the sftp server on port 2022, the root directory /data contains all files

## Sample docker-compose

```yaml
version: '3.2'
services:
  ftp:
    image: timoreymann/chrooted-ftp
    environment:
      - "BANNER=Welcome to my dockerized FTP!"
    # - PUBLIC_HOST=custom-host.domain.tld # optional and only used for passive ftp, defaults to localhost
    ports:
      # active ftp
      - "21:21"
      # passive ftp ports, may differ if you configured them differently
      - "10090-10100:10090-10100"

      # sftp
      - "2022:2022"
    volumes:
      # Sample mount for user foo
      - /var/www/html:/data/foo
      # Mount user list
      - ./ftp_users:/opt/chrooted-ftp/users
      # Make sure to keep host keys across restarts
      - ./ssh_host_keys:/opt/chrooted-ftp/ssh_hostkeys
```

## Configuration

### Users

Users can be configured using the `/opt/chrooted-ftp/users` file.

The syntax is `username:password`, once per line.

There is also the default user `bob` with password `s3cr3tCand!`. This user is gone at the moment you mount the users
file.

### FTP

You can further configure the ftp server using the following environment variables:

| Variable         | Usage                                              |
|:-----------------|:---------------------------------------------------|
| PASSIVE_MIN_PORT | Minimum used passive port                          |
| PASSIVE_MAX_PORT | Maximum used passive port                          |
| PUBLIC_HOST      | Public host                                        |
| UMASK            | customize the ftp umask (default 022 => chmod 777) |

### SFTP

> For SFTP there is currently no further configuration possible and necessary.

### General settings

| Variable    | Usage                                         |
|:------------|:----------------------------------------------|
| BANNER      | Banner displayed at connect using SFTP or FTP |

### Ports

> You must take care of opening/mapping the ports via docker to match your docker configuration.

Default ports are:

| Port        | Protocol    |
|:------------|:------------|
| 21          | Active FTP  |
| 10090-10100 | Passive FTP |
| 2022        | SFTP        |

I recommend exposing them as they are to the host, but you can also change them on the host.

See [docker docs](https://docs.docker.com/config/containers/container-networking/#published-ports) for more information.

For example usage, see the docker-compose example file above.

# Under the hood

Under the hood the image is based on alpine and vsftpd. So it size and resource usage is really low.

## Chroot(ing)

VSFTPD and SFTP work completely different when it comes to chroot.

VSFTPD works with the user homes out of the box while SFTP chroot requires the common start folder to be owned by root.

To make it work with both, the structure is like this:

```text
/data           | user root
    <user>      | Home folder, owned by root:root
        /data   | Data folder, owned by <user>
```

This structure allows FTP to acess the data directly, while via SFTP you need to prepend the path /data

