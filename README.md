chrooted-ftp
====
![GitHub Release](https://img.shields.io/github/v/tag/timo-reymann/chrooted-ftp.svg)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/timoreymann/chrooted-ftp)

A dead simple alpine-based docker container to allow users only access their own home directory.

## Why?!

The problem this container is solving is the following:
I want to provide ftp for some users, but i dont want to configure the chroot stuff and so on. 
So this container is doing exactly that. You can mount `/data` as your volume the subfolders are per user. 
So you can mount for example a website for a user under `/data/bob` and your host volume is `/var/www/bobs.homepage.digital`. Its just that simple.


## Okay so how do i use this

1. Add  user entry in form username:password into a file mounted under `/opt/chrooted-ftp/users`.
2. Mount the desired host volume under `/data/username`
3. Fire up the server. Dont forget to open port 21 (more about configuration is below)
4. Your user can connect to the ftp server, only seeing his own files


## Sample docker-compose

```yaml
version: '3.2'
services:
  ftp:
    image: timoreymann/chrooted-ftp
    environment:
      - "BANNER=Welcome to my dockerized FTP!"
#      - PUBLIC_HOST=192.168.0.1
    ports:
      # active ftp
      - "21:21"

      # passive ftp ports, may differ if you configured them differently
      - 10090-10100:10090-10100
    volumes:
      - /var/www/html:/data/foo
      - ./ftp_users:/opt/chrooted-ftp/users
```



## Configuration


### Users
Users can be configured using the /opt/chrooted-ftp/users file. 

The syntax is username:password, once per line.

There is also the default user `bob` with password `s3cr3tCand!`. This user is gone at the moment you mount the users file. 


### Passive FTP
You can configure passive ftp using the following environment variables:

| Variable          | Function                      |
| :--               | :---                          |
| PASSIVE_MIN_PORT  | Minimum used passive port     |
| PASSIVE_MAX_PORT  | Maximium used passive port    |

You must take care of opening/mapping the ports via docker to match your docker configuration.


### Umask
To customize the ftp umaks (default 022 => chmod 777) you can use the vnironment variable `UMASK`

### Misc

| Variable          | Function                      |
| :--               | :---                          |
| BANNER            | Banner displayed at connect   |
| PUBLIC_HOST       | Public host                   |
## Under the hood
Under the hood the image is based on alpine and vsftpd. So it size and resource usage is really low.
