# Lightweight Hosting with LXC and CentOS 9

## Install LXC + LibVirt

CentOS 9 Stream does not ship the `libvirt-daemon-lxc` and `libvirt-daemon-driver-lxc` driver.
Download the SRPM package from Fedora https://koji.fedoraproject.org/koji/buildinfo?buildID=2267746

Install the build dependencies
```bash
$ sudo dnf builddep libvirt-9.6.0-1.fc39.src.rpm
```

Install the libvirt SRPM 

```bash
$ rpm --install libvirt-9.6.0-1.fc39.src.rpm
```

Edit the spec `~/rpmbuild/SPECS/libvirt.spec` file: set the `with_lxc` variable to 1.

```
# RHEL doesn't ship many hypervisor drivers
%if 0%{?rhel}
    %define with_openvz 0
    %define with_vbox 0
    %define with_vmware 0
    %define with_libxl 0
    %define with_hyperv 0
    %define with_vz 0
    %define with_lxc 1
%endif
```

Build the RPM

```bash
$ rpmbuild -ba ~/rpmbuild/SPECS/libvirt.spec
```

Remove current libvirt if installed.

```
$ sudo dnf erase -y libvirt
```

Install `libvirt-driver-lxc`

```bash
$ cd ~/rpmbuild/RPMS/x86_64/
$ sudo dnf install -y libvirt-daemon-9.6.0-1.el9.x86_64.rpm \
  libvirt-daemon-lock-9.6.0-1.el9.x86_64.rpm                \ 
  libvirt-daemon-log-9.6.0-1.el9.x86_64.rpm                 \
  libvirt-daemon-plugin-lockd-9.6.0-1.el9.x86_64.rpm        \
  libvirt-daemon-proxy-9.6.0-1.el9.x86_64.rpm               \
  libvirt-daemon-driver-lxc-9.6.0-1.el9.x86_64.rpm          \
  libvirt-daemon-common-9.6.0-1.el9.x86_64.rpm              \
  libvirt-daemon-driver-network-9.6.0-1.el9.x86_64.rpm      \
  libvirt-libs-9.6.0-1.el9.x86_64.rpm                       \
  libvirt-libs-9.6.0-1.el9.x86_64.rpm                       \
  libvirt-daemon-driver-storage-rbd-9.6.0-1.el9.x86_64.rpm  \
  libvirt-daemon-driver-storage-core-9.6.0-1.el9.x86_64.rpm
```

Download the virt-bootstrap SRPM:

```
$ wget https://kojipkgs.fedoraproject.org//packages/virt-bootstrap/1.1.1/20.fc39/src/virt-bootstrap-1.1.1-20.fc39.src.rpm
```

Build the SRPM:

```
$ rpmbuild --rebuild virt-bootstrap-1.1.1-20.fc39.src.rpm
```

Install the virt-bootstrap package:

```
$ sudo dnf install -y virt-bootstrap-1.1.1-20.fc39.rpm
```

Create the `vps` user. This user will create the containers and run them. You can also create a user for each VPS container, just add it to the `libvirt` group.

```
$ sudo useradd -m -g vps -G libvirt -c 'VPS user' -d /home/vps vps
```

Create a sudo entry to enable the `vps` user to copy files.

```
cat <<EOF > /etc/sudoers.d/vps
> Cmnd_Alias VPS = /bin/cp, /bin/rm
%vps    ALL=(ALL) NOPASSWD: VPS
EOF
```

Create an image template from a OCI container image using the [vpsctl](https://github.com/SotolitoLabs/sotolito-vps/blob/master/imgctl) script:

```
$ imgctl generate centos:stream9
$ ln -s centos:stream9 sotolito-vps-base
```

Copy the template to a new directory for the container image:

```
$ sudo cp -rp sotolito-vps-base testlxc
```

Set the VIRSH_DEFAULT_CONNECT_URI variable to use the global libvirt settings:

```
$ export VIRSH_DEFAULT_CONNECT_URI=lxc:///system
```

Start the container:

```
$ virsh start testlxc
```

# References
* https://libvirt.org/drvlxc.html
* https://koji.fedoraproject.org/koji/buildinfo?buildID=2267746
* https://kojipkgs.fedoraproject.org//packages/virt-bootstrap/1.1.1/20.fc39/src/virt-bootstrap-1.1.1-20.fc39.src.rpm