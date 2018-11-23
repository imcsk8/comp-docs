# Dovecot IMAP with LDAP

This document details how to configure dovecot with LDAP in Fedora

## Install Dovecot and dependencies

**Install Dovecot and sasl support**

```
# dnf install -y cyrus-sasl cyrus-sasl-ldap dovecot
```

**Configure basic dovecot**

*In /etc/dovecot/dovecot.conf* 
```
protocols = imap lmtp
```


## Configure Authentication

We'll use AuthBinds, this way the LDAP server takes care of password authentication.


*In /etc/dovecot/conf.d/10-auth.conf* 
```
disable_plaintext_auth = no
auth_mechanisms = plain login

```

*In /etc/dovecot/conf.d/auth-ldap.conf.ext*
```
 passdb {
  driver = ldap

  # Path for LDAP configuration file, see example-config/dovecot-ldap.conf.ext
  args = /etc/dovecot/conf.d/dovecot-ldap.conf.ext
}

userdb {
  driver = ldap
  args = /etc/dovecot/conf.d/dovecot-ldap.conf.ext

  # Default fields can be used to specify defaults that LDAP may override
  #default_fields = home=/home/virtual/%u
}

 
```

*In /etc/dovecot/conf.d/dovecot-ldap.conf.ext*

```
hosts = localhost
auth_bind = yes # The LDAP server handles the authentication
base = dc=aumenta,dc=com,dc=mx
scope = subtree
user_filter = (&(objectClass=CourierMailAccount)(uid=%u)) 
#or
#user_filter = (&(objectClass=PosixAccount)(uid=%u))
blocking = yes
```

## Open Firewall port

```
# firewall-cmd --add-service={pop3,imap,imaps} --permanent 
# firewall-cmd --reload
```

## Test Dovecot

**Test**
```
# nc localhost 143
* OK [CAPABILITY IMAP4rev1 SASL-IR LOGIN-REFERRALS ID ENABLE IDLE LITERAL+ STARTTLS AUTH=PLAIN AUTH=LOGIN] Welcome to SotolitoOS Mailer.
A001 LOGIN user@example.com userpass

a001 OK [CAPABILITY IMAP4rev1 SASL-IR LOGIN-REFERRALS ID ENABLE IDLE SORT SORT=DISPLAY THREAD=REFERENCES THREAD=REFS THREAD=ORDEREDSUBJECT MULTIAPPEND URL-PARTIAL CATENATE UNSELECT CHILDREN NAMESPACE UIDPLUS LIST-EXTENDED I18NLEVEL=1 CONDSTORE QRESYNC ESEARCH ESORT SEARCHRES WITHIN CONTEXT=SEARCH LIST-STATUS BINARY MOVE SNIPPET=FUZZY LITERAL+ NOTIFY SPECIAL-USE] Logged in
```

## Troubleshooting

### SELinux

We all love to hate SELinux but it's useful just don't rely on it as the sole security strategy.

```
# grep imap /var/log/audit/audit.log  | audit2allow -M sotolito-imap
# semodule -i sotolito-imap.pp
# setsebool -P use_nfs_home_dirs 1
```




# References

* https://wiki2.dovecot.org/AuthDatabase/LDAP
* https://wiki2.dovecot.org/AuthDatabase/LDAP/AuthBinds
* https://www.server-world.info/en/note?os=Fedora_25&p=mail&f=2
* https://wiki.dovecot.org/TestInstallation

