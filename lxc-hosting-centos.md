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
  libvirt-daemon-driver-storage-core-9.6.0-1.el9.x86_64.rpm
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
  <name>test-lxc-virtman</name>                                                                                                                                                                                    
  <uuid>e21bd347-b8b9-4c56-8c2c-64e968b95167</uuid>                                                                                     
  <memory unit='KiB'>524288</memory>                                                                                                    
  <currentMemory unit='KiB'>524288</currentMemory>                                                                                      
  <vcpu placement='static'>1</vcpu>                 
  <resource>                                        
    <partition>/machine</partition>                 
  </resource>                                       
  <os>                                              
    <type arch='x86_64'>exe</type>                  
    <init>/sbin/init</init>                         
  </os>                                                                                                  
  <features>                                        
    <privnet/>                                      
  </features>                                       
  <clock offset='utc'/>                                                                                  
  <on_poweroff>destroy</on_poweroff>                                                                     
  <on_reboot>restart</on_reboot>                                                                         
  <on_crash>destroy</on_crash>                      
  <devices>                                         
    <emulator>/usr/libexec/libvirt_lxc</emulator>                                                        
    <filesystem type='mount' accessmode='mapped'>                                                        
      <source dir='/home/vservers/OCI-Image-Bundles/testlxc/rootfs'/>                                                                   
      <target dir='/'/>                             
    </filesystem>                                                                                        
    <filesystem type='mount' accessmode='mapped'>                                                        
      <source dir='/home/vservers/OCI-Image-Bundles/testlxc/etc'/>                                                                      
      <target dir='/etc'/>                          
    </filesystem>                                                                                        
    <filesystem type='mount' accessmode='mapped'>                                                        
      <source dir='/home/vservers/OCI-Image-Bundles/testlxc/var'/>                                       
      <target dir='/var'/>                          
    </filesystem>                                                                                        
    <filesystem type='mount' accessmode='mapped'>                                                        
      <source dir='/home/vservers/OCI-Image-Bundles/testlxc/html'/>                                                                     
      <target dir='/usr/share/nginx/html'/>                                                                                             
    </filesystem>                                   
    <filesystem type='mount' accessmode='mapped'>                                                        
      <source dir='/home/vservers/OCI-Image-Bundles/testlxc/home'/>                                                                     
      <target dir='/home'/>                         
    </filesystem>                                   
    <interface type='network'>                      
      <mac address='00:16:3e:e8:57:5a'/>                                                                                                
      <source network='default'/>                   
    </interface>                                    
    <console type='pty'>                                            
      <target type='lxc' port='0'/>                 
    </console>                                                      
  </devices>                                                        
</domain> 
```

Add the domain to libvirt:

```bash
$ virsh define testdomain.xml
```

Start the container:

```bash
$ virsh start testlxc
```

# References
* https://libvirt.org/drvlxc.html
* https://koji.fedoraproject.org/koji/buildinfo?buildID=2267746
* https://kojipkgs.fedoraproject.org//packages/virt-bootstrap/1.1.1/20.fc39/src/virt-bootstrap-1.1.1-20.fc39.src.rpm
