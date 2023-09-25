# Postfix + LDAP + Spamassassin + amavis + Clamav + Postgrey + letsencrypt

Postfix SMTP with spam, graylist and virus check and LDAP aduthentication.

## Installation

```
dnf install -y postfix postfix-ldap spamassassin amavis clamav perl-ClamAV-Client clamav-server-systemd clamav-scanner-systemd  clamav-filesystem clamav-update postgrey opendkim
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

Change the user in /etc/tmpfiles.d/opendkim.conf
```
D /var/run/opendkim 0700 postfix postfix -
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

### Postgrey

Gray lists

In /etc/sysconfig/postgrey:

```
POSTGREY_OPTS="--inet=127.0.0.1:30"
```

Start postgrey so it generates the SELinux avc messages needed to generate it's policy.
```
# systemctl enable postgrey
# systemctl start postgrey
```

**SELinux**
```
# grep postgrey /var/log/audit/audit.log  | audit2allow -M sotolito_postgrey
# semodule -i sotolito_postgrey.pp
### For some reason that i haven't checked you need to generate other policy file
# grep postgrey /var/log/audit/audit.log  | audit2allow -M sotolito_postgrey2
# semodule -i sotolito_postgrey2.pp
```


## Open Ports

```
# firewall-cmd --permanent --add-service={smtp,smtps}
success
# firewall-cmd --permanent --add-port=587/tcp
success
# firewall-cmd --reload
```

## Configure clamav

Configure clamav updates
```

```

### Configure Amavis

**SELinux**
```
# restorecon -R -v /var/amavis/
# setsebool -P nis_enabled 1

```

## Letsencrypt
Create certificates using dns challenge:
```
# cd /etc/letsencrypt
# wget https://github.com/joohoi/acme-dns-certbot-joohoi/raw/master/acme-dns-auth.py
# chmod +x acme-dns-auth.py
# certbot certonly --manual --manual-auth-hook /etc/letsencrypt/acme-dns-auth.py --preferred-challenges dns --debug-challenges -d smtp.example.com
# cd /etc/postfix
# mkdir tls
# cd tls
# ln -s /etc/letsencrypt/live/smtp.example.com/privkey.pem example.com.key.pem
# ln -s /etc/letsencrypt/live/smtp.example.com/cert.pem example.com.cert.pem
```

Add configuration to `main.cf`

```
mtpd_use_tls = yes
#smtpd_tls_auth_only = yes
smtpd_tls_key_file = /etc/postfix/ssl/example.com.key.pem
smtpd_tls_cert_file = /etc/postfix/ssl/example.com.cert.pem
smtpd_tls_loglevel = 3
smtpd_tls_received_header = yes
smtpd_tls_session_cache_timeout = 3600s
tls_random_source = dev:/dev/urandom
```

## References
* https://www.hiroom2.com/2017/07/12/fedora-26-clamav-en/
