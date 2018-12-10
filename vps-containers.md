# Virtual Private Server using containers

Containers are very popular for microservices and their other use cases tend to be overlooked. Since containers provide isolation for Operating System Virtualization, they can be used as VPS's.

## Architecture

In order to have the best of both worlds we'll consider our container as a disposable unit having the configuration and data volumes mounted from the host filesystem.

The container should mount the /etc, /home and /var as external volumes.

The http traffic will be routed in the host with haproxy.
The ssh traffil will be routed using iptables rules.

## Implementation

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
*We can also use buildah*

```
# buildah bud -f Dockerfile  -t sotolito-vps-base
```

For a VPS an init system is needed, as we can see in the Dockerfile we'll use the default init system of the distribution.
Instead of using (Docker)[https://www.docker.com/] for our containers we'll use (runc)[https://github.com/opencontainers/runc] since it plays very well with systemd.

**Create the OCI container bundle**

Extract the rootfs
```
# mkdir rootfs
# docker export $(docker create sotolito-vps-base) | tar -C rootfs -xvf -
```

Create the spec file
```
# runc spec
```

Networking

Networking sucks so we need this little tool
```
# go get github.com/genuinetools/netns
```

**Modify config.json**

Disable terminal 

```
{
        "ociVersion": "1.0.1-dev",
        "process": {
                "terminal": false,
```

Extend capabilities for systemd containers
```
  		"capabilities": {
			"bounding": [
                		"CAP_SYS_ADMIN",
                		"CAP_SYS_TIME",
		                "CAP_SYS_CHROOT",
             			"CAP_CHOWN",
		                "CAP_SETUID",
                		"CAP_SETGID",
               			"CAP_FOWNER",
                		"CAP_DAC_OVERRIDE",
                		"CAP_FSETID",
                		"CAP_SETFCAP",
                		"CAP_KILL",
                		"CAP_SETPCAP",
                		"CAP_NET_BIND_SERVICE",
                		"CAP_NET_RAW",
                		"CAP_NET_BROADCAST",
                		"CAP_AUDIT_WRITE"
			],
			"effective": [
				"CAP_SYS_ADMIN",
                		"CAP_SYS_TIME",
                		"CAP_SYS_CHROOT",
                		"CAP_CHOWN",
                		"CAP_SETUID",
                		"CAP_SETGID",
                		"CAP_FOWNER",
                		"CAP_DAC_OVERRIDE",
                		"CAP_FSETID",
                		"CAP_SETFCAP",
                		"CAP_KILL",
                		"CAP_SETPCAP",
                		"CAP_NET_BIND_SERVICE",
                		"CAP_NET_RAW",
                		"CAP_NET_BROADCAST",
                		"CAP_AUDIT_WRITE"
		    ],
			"inheritable": [
 	            		"CAP_SYS_ADMIN",
                		"CAP_SYS_TIME",
                		"CAP_SYS_CHROOT",
                		"CAP_CHOWN",
                		"CAP_SETUID",
                		"CAP_SETGID",
                		"CAP_FOWNER",
                		"CAP_DAC_OVERRIDE",
                		"CAP_FSETID",
                		"CAP_SETFCAP",
                		"CAP_KILL",
                		"CAP_SETPCAP",
                		"CAP_NET_BIND_SERVICE",
                		"CAP_NET_RAW",
                		"CAP_NET_BROADCAST",
                		"CAP_AUDIT_WRITE"
			],
			"permitted": [
	            		"CAP_SYS_ADMIN",
                		"CAP_SYS_TIME",
                		"CAP_SYS_CHROOT",
                		"CAP_CHOWN",
                		"CAP_SETUID",
                		"CAP_SETGID",
                		"CAP_FOWNER",
                		"CAP_DAC_OVERRIDE",
                		"CAP_FSETID",
                		"CAP_SETFCAP",
                		"CAP_KILL",
                		"CAP_SETPCAP",
                		"CAP_NET_BIND_SERVICE",
                		"CAP_NET_RAW",
                		"CAP_NET_BROADCAST",
                		"CAP_AUDIT_WRITE"
			],
			"ambient": [
	            		"CAP_SYS_ADMIN",
                		"CAP_SYS_TIME",
               			"CAP_SYS_CHROOT",
                		"CAP_CHOWN",
                		"CAP_SETUID",
                		"CAP_SETGID",
                		"CAP_FOWNER",
                		"CAP_DAC_OVERRIDE",
                		"CAP_FSETID",
                		"CAP_SETFCAP",
                		"CAP_KILL",
                		"CAP_SETPCAP",
                		"CAP_NET_BIND_SERVICE",
                		"CAP_NET_RAW",
                		"CAP_NET_BROADCAST",
                		"CAP_AUDIT_WRITE"
			]
		},
```

Add VPS specific persistent directories

```
	"mounts": [
		{
			"destination": "/etc",
			"type": "bind",
			"source": "/home/vps/users/user1/etc",
                        "options": [
                            "bind",
                            "rw"
                        ]
			"destination": "/var",
			"type": "bind",
			"source": "/home/vps/users/user1/var",
                        "options": [
                            "bind",
                            "rw"
                        ]
			"destination": "/home",
			"type": "bind",
			"source": "/home/vps/users/user1/home",
                        "options": [
                            "bind",
                            "rw"
                        ]

```

Networking for conainers
```
        "hooks": {
                "prestart": [
                {
                        "path": "/home/vservers/OCI-Image-Bundles/utils/bin/netns"
                }
                ]
        }
```

Get the /var and /etc directories from the rootfs (this has to be created for each VPS)
```
# mkdir -p /home/vps/users/vps-guest1
# cp -rp rootfs/etc /home/vps/users/vps-guest1/etc
# cp -rp rootfs/var /home/vps/users/vps-guest1/var
# cp -rp rootfs/home /home/vps/users/vps-guest1/home
```

**Use a systemd unit for each VPS.**

Create systemd template unit file: sotolito-vps@.service, this file

```
[Unit]
Description=Sotolito VPS %i
After=network.target

[Service]
Slice=machine.slice
Delegate=true
CPUWeight=100
MemoryLimit=512M
#TimeoutSec=300
EnvironmentFile=/etc/systemd/system/sotolito-vps.target.wants/%i.cfg
ExecStart=/home/vservers/OCI-Image-Bundles/utils/sotolito-vps/vpsctl start %i
ExecStop=/home/vservers/OCI-Image-Bundles/utils/sotolito-vps/vpsctl stop %i
KillMode=mixed
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.targ
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

Run the container
```
/usr/bin/runc --systemd-cgroup run test-vps-container
```


## Networking

### IPTables

Allow containers to access the internet
```
# iptables -t nat -A POSTROUTING -o enp9s0 -j MASQUERADE
# iptables -I FORWARD -i netns0 -o enp9s0 -j ACCEPT
# iptables -I FORWARD -i enp9s0 -o netns0 -m state --state RELATED,ESTABLISHED -j ACCEPT

```

### HAProxy

```
TODO
```

## Troubleshooting

* Kill a container
```
runc kill mycontainer KILL
```

## References

* https://coreos.com/rkt/docs/latest/using-rkt-with-systemd.html
* https://coreos.com/rkt/
* https://container-solutions.com/running-docker-containers-with-systemd/
* https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/container_security_guide/docker_selinux_security_policy
* https://github.com/SotolitoLabs/sotolito-vps


