# Testing OpenShift with minishift on Fedora

Minishift is a fork of minikube focues on provisioning OpenShift locally by running a single node
OpenShift inside a VM.

## Prerequisites

**Install KVM**

```
# dnf install libvirt qemu-kvm
# systemctl enable libvirtd
# systemctl start libvirtd
```

**Prepare user**

```
# usermod -a -G libvirt myuser
```

**Login as "myuser" or update user groups**

```
$ newgrp libvirt
```

**Install the KVM driver for docker machine**

*This is just plain wrong, Fedora should package this puppy*

```
# curl -L https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.10.0/docker-machine-driver-kvm-centos7 -o /usr/local/bin/docker-machine-driver-kvm
# chmod +x /usr/local/bin/docker-machine-driver-kvm
```

## Install Minishift

*This also should be packaged*


**Download and install from the website like a caveman**

```
$ cd /usr/src
$ curl -L https://github.com/minishift/minishift/releases/download/v1.30.0/minishift-1.30.0-linux-amd64.tgz -o minishift-1.30.0-linux-amd64.tgz
$ cd /usr/local
$ tar -zxvf /usr/src/minishift/minishift-1.30.0-linux-amd64.tgz
$ ln -s minishift-1.30.0-linux-amd64 minishift
$ export PATH=$PATH:/usr/local/minishift
```














## References

* https://docs.okd.io/latest/minishift/getting-started/index.html
* https://github.com/minishift/minishift
