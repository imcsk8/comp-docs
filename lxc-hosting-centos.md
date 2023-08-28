# Lightweight Hosting with LXC and CentOS 9

## Install LXC + LibVirt

CentOS 9 Stream does not ship the `libvirt-daemon-lxc` and `libvirt-daemon-driver-lxc` driver.
Download the SRPM package from Fedora https://koji.fedoraproject.org/koji/buildinfo?buildID=2267746

Install the build dependencies
```bash
$ sudo dnf builddep libvirt-9.6.0-1.fc39.src.rpm
```

Install the SRPM 

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

Install `libvirt-driver-lxc`

```bash
$ cd ~/rpmbuild//RPMS/x86_64/
$ sudo dnf install -y libvirt-daemon-driver-lxc-9.6.0-1.el9.x86_64.rpm
```
