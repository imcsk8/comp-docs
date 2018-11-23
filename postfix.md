# Postfix + LDAP + Spamassassin + amavis + Clamav + Postgrey

Postfix SMTP with spam, graylist and virus check and LDAP aduthentication.

## Installation

```
dnf install -y postfix spamassassin amavis clamav perl-ClamAV-Client clamav-server-systemd clamav-scanner-systemd  clamav-filesystem clamav-update postgrey
```

## Open Ports

```
# firewall-cmd --permanent --add-service=smtps
success
# firewall-cmd --permanent --add-port=587/tcp
success
# firewall-cmd --reload
```

*Keep port 25 closed to the outside for spam prevention*

## Configure clamav

Configure clamav updates
```

```


## References
* https://www.hiroom2.com/2017/07/12/fedora-26-clamav-en/
