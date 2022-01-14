# ELRepo Kernel with SecureBoot



```
$ sudo -i
# wget https://elrepo.org/SECURE-BOOT-KEY-elrepo.org.der -O /etc/pki/elrepo/SECURE-BOOT-KEY-elrepo.org.der
# mokutil --import /etc/pki/elrepo/SECURE-BOOT-KEY-elrepo.org.der
input password: 
input password again: 
```

Reboot the system an follow the steps to enroll the key.

## References
* http://elrepo.org/tiki/SecureBootKey
