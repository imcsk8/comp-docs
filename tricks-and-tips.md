# Linux Tricks and Tips

## Shell

* **Remove string with newline using sed**
```
 sed -i -e ':a' -e 'N' -e '$!ba' -e  's/string to remove\n//g' file
```

* **Check IMAP SSL connection**
```
# openssl s_client -connect imap.gmail.com:993 
```

* **Fedora Systemd /etc/passwd manual changes**
Fedora comes with a System Security Services Daemon that manage access to remote directories and authentication mechanisms, it caches /etc/passwd in the /var/lib/sss/mc/passwd file.
If you make a manual change to /etc/passwd the sssd cache must be deleted this way:

```
# systemctl stop sssd
# rm /var/lib/sss/mc/passwd
# systemctl start sssd
```
