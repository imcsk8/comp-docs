# Postfix + LDAP + Spamassassin + amavis + Clamav + Postgrey

Postfix SMTP with spam, graylist and virus check and LDAP aduthentication.

## Installation

```
dnf install -y postfix spamassassin amavis clamav perl-ClamAV-Client clamav-server-systemd clamav-scanner-systemd  clamav-filesystem clamav-update postgrey opendkim
```

### OpenDKIM

In opendkim.conf
```
LogWhy            Yes
Syslog            yes
SyslogSuccess     yes
#Socket           inet:8891@localhost
Socket            local:/var/run/opendkim/opendkim.sock
ReportAddress     dkim@gmail.com
SendReports       yes
#UserID            milter
UserID            postfix
PidFile           /var/run/opendkim/opendkim.pid

Mode              s
Canonicalization  relaxed/simple
#Statistics        /var/lib/opendkim/stats.dat

Domain           /etc/opendkim/domains.txt
KeyTable         /etc/opendkim/KeyTable
SigningTable     refile:/etc/opendkim/SigningTable
```

Set permissions

```
# chown -R postfix:postfix /var/run/opendkim
```

Set user on systemd unit

```
# cp /usr/lib/systemd/system/opendkim.service /etc/systemd/system/opendkim.service
```

Edit /etc/systemd/system/opendkim.service

```
User=postfix
Group=postfix
```


Start 
```
# systemctl enable opendkim
# systemctl start opendkim
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
