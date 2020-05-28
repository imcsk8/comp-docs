# Akmod for custom kernel in Fedora

Download the Fedora kernel package and the linux sources, configure them and create the RPM package.

## Custom kernel creation

## Download kernel source RPM
### Using fedpkg

```
$ fedpkg clone kernel
```

### Using SRPM from repository
```
$ dnf download --source kernel
```

**Switch to your desired branch**

```
$ fedpkg switch-branch f31
```

### Download Kernel source using git

Get the stable version of the kernel:

```
$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
```

### Configure the kernel

#### Copy the kernel configuration from the SRPM tree

```
~$ cp kernel/kernel-x86_64-fedora.config linux-stable/.config
```

Menuconfig is a nice way to configure the kernel.

```
$ cd linux-stable
linux-stable $ make menuconfig
```

#### Optionally build the kernel and test it

```
linux-stable $ make -j 4 bzImage && make -j 4 modules && mane modules_install
```

#### Copy the new kernel configuration to the SRPM

```
linux-stable $ cp .config ../kernel/kernel-x86_64-fedora.config
```

### Create a kernel tarball

```
linux-stable $ git archive --format=tar.gz --prefix=linux-5.7.001 -o ../linux-5.7.001.tar.gz v5.7.001
```

### Copy the tarball to the rpm sources directory

```
linux-stable $ cp ../linux-5.7.001.tar.gz ~/rpmbuild/SOURCES/
```

## Modify source RPM

Edit the `kernel.spec` file:

```
...
%global baserelease rc7
...
%define base_sublevel 7
...
%define stable_update 0
...
%define rpmversion 5.%{upstream_sublevel}.0.imcsk8
...
%define buildid .local
...
```

### Create new kernel package

```
kernel $ sudo dnf install -y audit-libs-devel binutils-devel  java-devel libcap-devel libcap-ng-devel llvm-toolset net-too
ls newt-devel numactl-devel pciutils-devel  perl perl-devel python3-devel python3-docutils xmlto xz-devel elfutils-devel
kernel $ cp -rp * ~/rpmbuild/SOURCES/
kernel $ rpmbuild --define='fedora 31'  --define='dist .fc31' --without debug --target x86_64  -ba kernel.spec 2>&1 | tee 
build.log
```

_There might be some patches that don't apply, just comment them in the kernel.spec file_

## Custom akmod package

In this example, we will create a wl-kmod package for a broadcom wireless card.

### Install the required packages

```
~# dnf install -y akmod-wl broadcom-wl
```

### Edit the module package

```
~$ dnf download --source kmod-wl
~$ rpm -Uvh kmod-wl
```
