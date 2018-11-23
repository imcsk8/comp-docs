# SELinux notes

SELinux is a Linux kernel security module that provides a mechanism for supporting access control security policies, including mandatory access controls.

*SELinux is annoying as fuck and i used to disable it but it's better than nothing (obviously is not the only resurce you need to secure a Linux system but everything adds up) so we have to know how to tame it*

## Common usage

Most of the time you can fix stuff getting ```setsebool``` or ```restorecon``` examples from google but sometimes you have to create policies for custom settings on you OS.

## audit2allow

audit2allow generates SELinux policies based on denial errors. This errors can be checked via the ```journalctl``` command or the ```/var/log/audit/audit.log``` file.





## Fuck it just tell me how to disable it!!

* To disable SELinux permanently:

In /etc/selinux/config set:
```
SELINUX=permissive
```
If you want to still get warnings.

If you are annoyed in a hurry or just don't care about security disable it completely:

```
SELINUX=disabled
```

* To disable SELinux tempoarily

```
# setenforce 0
```




## References

* https://en.wikipedia.org/wiki/Security-Enhanced_Linux
* https://www.tecmint.com/disable-selinux-temporarily-permanently-in-centos-rhel-fedora/
* https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security-enhanced_linux/sect-security-enhanced_linux-fixing_problems-allowing_access_audit2allow

