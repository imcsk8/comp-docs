# Virtual Private Server using containers

Containers are very popular for microservices and their other use cases tend to be overlooked. Since containers provide isolation for Operating System Virtualization, they can be used as VPS's.

## Architecture

In order to have the best of both worlds we'll consider our container as a disposable unit having the configuration and data volumes mounted from the host filesystem.

The docker container should mount the /etc and /var as external volumes.

Our basic VPS container is going to server web apps so we'll start with this Dockerfile to create a base image.

```
FROM fedora:29
ENV container docker
ARG password=examplepass
RUN dnf -y install nginx openssh-server openssh-clients procps-ng passwd mariadb-server php-fpm
RUN dnf clean all
RUN systemctl enable sshd nginx
RUN groupadd sotolito 
RUN useradd -g sotolito -s /bin/bash -c 'SotolitoLabs User' -d /home/sotolito sotolito
RUN echo $password | passwd --stdin sotolito
RUN chage -d 0 sotolito
RUN echo "sotolito-container" > /etc/hostname
STOPSIGNAL SIGRTMIN+3
EXPOSE 80 22
CMD [ "/sbin/init" ]

```

*For now We'll use docker for building the images*

```
# docker build -t sotolito-vps .
```

For a VPS an init system is needed, as we can see in the Dockerfile we'll use the default init system of the distribution.
Instead of using (Docker)[https://www.docker.com/] for our containers we'll use (runc)[https://github.com/opencontainers/runc] since it plays very well with systemd.

**Use a systemd unit for each VPS.**

Create systemd template unit file: sotolito-vps@.service, this file

```
[Unit]
Description=Sotolito VPS
After=docker.service
Requires=docker.service
 
[Service]
Slice=machine.slice
Delegate=true
CPUWeight=100
MemoryLimit=512M
TimeoutSec=300
EnvironmentFile=/etc/systemd/system/sotolito-vps.target.wants/%i.cfg
ExecStart=/usr/bin/runc run --systemd-cgroup machine.slice -d --name %i -b sotolito-vps-base
ExecStopPost=/usr/bin/runc delete %i
KillMode=mixed
Restart=always
RestartSec=10s
Type=forking
NotifyAccess=all
 
[Install]
WantedBy=multi-user.target
```

Copy the unit file to the systemd directory and reload daemons.

*As root*
```
# cp sotolito-vps@.service /usr/lib/systemd/system/
# sudo systemctl daemon-reload
```

This is a template unit file, the VPS's units are referenced as symlinks in the */etc/systemd/system/sotolito-vps.target.wants* with names like: sotolito-vps@vps-1.service for the vps-1 VPS.

*As root*
```
# mkdir /etc/systemd/system/sotolito-vps.target.wants
# ln -s /usr/lib/systemd/system/sotolito-vps@.service  sotolito-vps@sotolitolabs-vps.service
```


Configuration file sotolitolabs-vps.cfg:

```
VPS_IP=172.18.0.11
VPS_NET=sotolito-vps-net
```

## References

* https://coreos.com/rkt/docs/latest/using-rkt-with-systemd.html
* https://coreos.com/rkt/
* https://container-solutions.com/running-docker-containers-with-systemd/
* https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/container_security_guide/docker_selinux_security_policy


