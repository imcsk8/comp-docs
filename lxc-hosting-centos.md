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

```bash
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
  libvirt-daemon-driver-storage-core-9.6.0-1.el9.x86_64.rpm \
  libvirt-daemon-driver-interface-9.6.0-1.el9.x86_64.rpm    \
  libvirt-daemon-driver-nodedev-9.6.0-1.el9.x86_64.rpm      \
  libvirt-daemon-driver-nwfilter-9.6.0-1.el9.x86_64.rpm     \
  libvirt-daemon-driver-storage-9.6.0-1.el9.x86_64.rpm      \
  libvirt-daemon-lxc-9.6.0-1.el9.x86_64.rpm                 \
  libvirt-daemon-driver-storage-disk-9.6.0-1.el9.x86_64.rpm  \
  libvirt-daemon-driver-storage-iscsi-9.6.0-1.el9.x86_64.rpm \
  libvirt-daemon-driver-storage-logical-9.6.0-1.el9.x86_64.rpm \
  libvirt-daemon-driver-storage-mpath-9.6.0-1.el9.x86_64.rpm   \
  libvirt-daemon-driver-storage-scsi-9.6.0-1.el9.x86_64.rpm    \
  systemd-container
```

Download the virt-bootstrap SRPM:

```bash
$ wget https://kojipkgs.fedoraproject.org//packages/virt-bootstrap/1.1.1/20.fc39/src/virt-bootstrap-1.1.1-20.fc39.src.rpm
```

Build the SRPM:

```bash
$ rpmbuild --rebuild virt-bootstrap-1.1.1-20.fc39.src.rpm
```

Install the virt-bootstrap package:

```bash
$ sudo dnf install -y virt-bootstrap-1.1.1-20.fc39.rpm
```

Create the `vps` user. This user will create the containers and run them. You can also create a user for each VPS container, just add it to the `libvirt` group.

```bash
$ sudo useradd -m -g vps -G libvirt -c 'VPS user' -d /home/vps vps
```

Create a sudo entry to enable the `vps` user to copy files.

```bash
cat <<EOF > /etc/sudoers.d/vps
> Cmnd_Alias VPS = /bin/cp, /bin/rm
%vps    ALL=(ALL) NOPASSWD: VPS
EOF
```

Create a CentOS Stream 9 OCI container image with systemd:

```bash
$ podman build --cgroup-manager cgroupfs -t sotolito-vps-base:1.0.0-centos9 .
```

Create an image template from a OCI container image using the [vpsctl](https://github.com/SotolitoLabs/sotolito-vps/blob/master/imgctl) script:

```bash
$ imgctl generate sotolito-vps-base:1.0.0-centos9
$ ln -s centos:stream9 sotolito-vps-base
```

Copy the template to a new directory for the container image:

```bash
$ sudo cp -rp sotolito-vps-base testlxc
```

Set the VIRSH_DEFAULT_CONNECT_URI variable to use the global libvirt settings:

```bash
$ export VIRSH_DEFAULT_CONNECT_URI=lxc:///system
```

Create the container libvirt domain file, the following can be used as starting point:

```bash
<domain type='lxc'>
  <name>vps-template</name>                                                                                                                       
  <memory unit='KiB'>524288</memory>                                                                                                              
  <currentMemory unit='KiB'>524288</currentMemory>                                                                                                
  <vcpu placement='static'>1</vcpu>                                                                                                               
  <resource>                                                                                                                                      
    <partition>/machine</partition>                                                                                                               
  </resource>                                                                                                                                     
  <os>                                                                                                                                            
    <type arch='x86_64'>exe</type>                                                                                                                
    <init>/sbin/init</init>                                                                                                                       
    <initenv name='container'>lxc-vps</initenv>                                                                                                   
  </os>                                                                                                                                           
  <idmap>                                                                                                                                         
    <uid start='0' target='65537' count='1001180000'/>                                                                                            
    <gid start='0' target='65535' count='1001180000'/>                                                                                            
  </idmap>                                                                                                                                        
  <features>                                                                                                                                      
    <privnet/>                                                                                                                                    
    <capabilities policy='default'>                                                                                                               
      <mknod state='on'/>                                                                                                                         
      <sys_admin state='on'/>                                                                                                                     
    </capabilities>                                                                                                                               
  </features>                                                                                                                                     
  <clock offset='utc'/>                                                                                                                           
  <on_poweroff>destroy</on_poweroff> 
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
<devices>
    <emulator>/usr/libexec/libvirt_lxc</emulator>
    <filesystem type='mount' accessmode='squash'>
      <source dir='/home/vservers/OCI-Image-Bundles/sotolito-vps-web:1.0.0-centos9/rootfs'/>
      <target dir='/'/>
    </filesystem>
    <filesystem type='mount' accessmode='squash'>
      <source dir='/home/vservers/OCI-Image-Bundles/sotolito-vps-web:1.0.0-centos9/etc'/>
      <target dir='/etc'/>
    </filesystem>
    <filesystem type='mount' accessmode='squash'>
      <source dir='/home/vservers/OCI-Image-Bundles/sotolito-vps-web:1.0.0-centos9/var'/>
      <target dir='/var'/>
    </filesystem>
    <filesystem type='mount' accessmode='squash'>
      <source dir='/home/vservers/OCI-Image-Bundles/sotolito-vps-web:1.0.0-centos9/html'/>
      <target dir='/usr/share/nginx/html'/>
    </filesystem>
    <filesystem type='mount' accessmode='squash'>
      <source dir='/home/vservers/OCI-Image-Bundles/sotolito-vps-web:1.0.0-centos9/home'/>
      <target dir='/home'/>
    </filesystem>
    <interface type='network'>
      <mac address='52:54:00:f8:08:1d'/>
      <source network='default' portid='8b55da8a-73c1-4ccc-9a68-69cf5d3bdfad' bridge='virbr0'/>
      <target dev='vnet18'/>
      <guest dev='eth0'/>
    </interface>
    <console type='pty' tty='/dev/pts/5'>
      <source path='/dev/pts/5'/>
      <target type='lxc' port='0'/>
      <alias name='console0'/>
    </console>
  </devices>
</domain>
```

Notice that with `<sys_admin state='on'/>` we're enableing `CAP_SYS_ADMIN` but only in the user namespace in which the VPS container runs.

To add a static IP addrees create a NetworkManager connection for the address range that is managed by libvirt, generally 
you can get this by checking out the `virbr0` interface IP:

```
$ ip addr show virbr0
14: virbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 52:54:00:b8:7f:2f brd ff:ff:ff:ff:ff:ff
    *inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0*
       valid_lft forever preferred_lft forever
```

Create the new Network Manager connection with the `nmcli` command and send the output to a file
in the `<VPS_DIRECTORY>/etc/NetworkManager/system-connections` directory. 
Notice that the `etc` directory is the one that gets mounted in `/etc` inside the container (libvirt domain).

```
$ nmcli --offline connection add type ethernet con-name lxc-vps \
  ipv4.addresses 192.168.122.2/24 ipv4.dns 192.168.122.1       \
  ipv4.method manual > <PATH_TO_VPS_DIRECTORY>/etc/NetworkManager/system-connections/lxc-vps.nmconnection
$ chmod 600 <PATH_TO_VPS_DIRECTORY>/etc/NetworkManager/system-connections/lxc-vps.nmconnection
```

Add the domain to libvirt:

```bash
$ virsh define vps-template.xml
```

Start the container with a normal user:

```bash
vps@hosting $ virsh start vps-template
```

This gives us a nice rootless VPS container:

![Captura de pantalla de 2023-09-05 11-54-39](https://github.com/imcsk8/comp-docs/assets/84400/4377c95e-b9fe-40b5-91c4-05ee9b0e0238)

Finally:
Do whatever you do with VPSs, be happy and have a beer or a coffee

# References
* https://libvirt.org/drvlxc.html
* https://koji.fedoraproject.org/koji/buildinfo?buildID=2267746
* https://kojipkgs.fedoraproject.org//packages/virt-bootstrap/1.1.1/20.fc39/src/virt-bootstrap-1.1.1-20.fc39.src.rpm
* https://systemd.io/CONTAINER_INTERFACE/
* https://man7.org/linux/man-pages/man7/user_namespaces.7.html
