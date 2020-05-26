# Akmod for custom kernel in Fedora

Download the Fedora kernel package and the linux sources, configure them and create the RPM package.

## Custom kernel creation

## Download kernel source RPM
### Using fedpkg

```
$ fedpkg clone kernel
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
$ git archive --format=tar.gz --prefix=linux-5.7.001 -o ../linux-5.7.001.tar.gz v5.7.001
```



## Modify source RPM

### Create new kernel package

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
