# ELRepo Kernel with SecureBoot

## Install ELRepo Sebure Boot Key

```
$ sudo -i
# wget https://elrepo.org/SECURE-BOOT-KEY-elrepo.org.der -O /etc/pki/elrepo/SECURE-BOOT-KEY-elrepo.org.der
# mokutil --import /etc/pki/elrepo/SECURE-BOOT-KEY-elrepo.org.der
input password: 
input password again: 
```

## Signing the kernel

The kernel-ml package is not signed so we have to sign it.

### Create the keys

```
TODO
```

### Sign the kernel

```
TODO
```

Reboot the system an follow the steps to enroll the key.

## References
* http://elrepo.org/tiki/SecureBootKey
* https://qastack.mx/ubuntu/1081472/vmlinuz-4-18-12-041812-generic-has-invalid-signature
