# SELinux notes

SELinux is a Linux kernel security module that provides a mechanism for supporting access control security policies, including mandatory access controls.

*SELinux is annoying as fuck and i used to disable it but it's better than nothing (obviously is not the only resurce you need to secure a Linux system but everything adds up) so we have to know how to tame it*

## Common usage

Most of the time you can fix stuff getting ```setsebool``` or ```restorecon``` examples from google but sometimes you have to create policies for custom settings on you OS.

## audit2allow

audit2allow generates SELinux policies based on denial errors. This errors can be checked via the ```journalctl``` command or the ```/var/log/audit/audit.log``` file.

For example if you have a dovecot IMAP server and it can't access the mail directories with an error like this:
```
type=AVC msg=audit(1543001562.316:9797): avc:  denied  { write } for  pid=26077 comm="imap" name="imcsk8" dev="sdc1" ino=7014287 scontext=system_u:system_r:dovecot_t:s0 tcontext=system_u:object_r:nfs_t:s0 tclass=dir permissive=0
```

To get more info about this problem:

```
# audit2allow -w -a
```

The relevant output for this problem should be something like this:

```
type=AVC msg=audit(1542867852.741:2588): avc:  denied  { name_bind } for  pid=17022 comm="dovecot" src=587 scontext=system_u:system_r:dovecot_t:s0 tcontext=system_u:object_r:smtp_port_t:s0 tclass=tcp_socket permissive=0
        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.
```

Create the custom rule

```
# grep dovecot /var/log/audit/audit.log  | audit2allow -M sotolito-dovecot
```

Add the module:

```
# semodule -i sotolito-dovecot
```


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
* https://danwalsh.livejournal.com/24750.html
