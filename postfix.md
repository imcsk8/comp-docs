# Postfix + LDAP + Spamassassin + amavis + Clamav + Postgrey

Postfix SMTP with spam, graylist and virus check and LDAP aduthentication.

## Installation

```
dnf install -y postfix spamassassin amavis clamav perl-ClamAV-Client clamav-server-systemd clamav-scanner-systemd  clamav-filesystem clamav-update postgrey
```


## Configure clamav

Configure clamav updates
```

```


## References
* https://www.hiroom2.com/2017/07/12/fedora-26-clamav-en/