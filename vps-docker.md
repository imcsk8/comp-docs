# Virtual Private Server using docker containers

Containers are very popular for microservices and their other use cases tend to be overlooked. Since containers provide isolation for Operating System Virtualization, they can be used as VPS's.

## Architecture

In order to have the best of both worlds we'll consider our container as a disposable unit having the configuration and data volumes mounted from the host filesystem.

The docker container should mount the /etc and /var as external volumes.

Our basic VPS container is going to server web apps so we'll start with this Dockerfile to create a base image.

```
FROM fedora:29a
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

Since we're gonna have static ip's for our VPS's we need a user defined network:

Create a new docker network

```
# docker network create --subnet=172.18.0.0/16 sotolito-vps-net

```

## References

* https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/container_security_guide/docker_selinux_security_policy
* https://github.com/ibuildthecloud/systemd-docker

