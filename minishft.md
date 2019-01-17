# Testing OpenShift with minishift on Fedora

Minishift is a fork of minikube focues on provisioning OpenShift locally by running a single node
OpenShift inside a VM.

## Requisites

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

*This is just plain wrong, Fedora should package this puppy**

```
# curl -L https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.10.0/docker-machine-driver-kvm-centos7 -o /usr/local/bin/docker-machine-driver-kvm
# chmod +x /usr/local/bin/docker-machine-driver-kvm
```











## References

* https://docs.okd.io/latest/minishift/getting-started/index.html
* https://github.com/minishift/minishift
