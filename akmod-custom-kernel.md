= Akmod for custom kernel in Fedora

== Custom kernel creaton

==== Download kernel source RPM
==== Modify source RPM
==== Create new kernel package

== Custom akmod package

In this example, we will create a wl-kmod package for a broadcom wireless card.

=== Install the required packages

```
~# dnf install -y akmod-wl broadcom-wl
```

=== Edit the module package

```
~$ dnf download --source kmod-wl
~$ rpm -Uvh kmod-wl
```
