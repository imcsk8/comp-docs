# Dovecot IMAP with LDAP

This document details how to configure dovecot with LDAP in Fedora

## Install Dovecot and dependencies

**Install Dovecot and sasl support**

```
# dnf install -y cyrus-sasl cyrus-sasl-ldap dovecot
```

**Configure basic dovecot**

*In /etc/dovecot/dovecot.conf 
```
protocols = imap lmtp submission
```


## Configure Authentication

We'll use AuthBinds, this way the LDAP server takes care of password authentication.


*In /etc/dovecot/conf.d/10-auth.conf 
```
disable_plaintext_auth = no
auth_mechanisms = plain login

```

*In /etc/dovecot/conf.d/auth-ldap.conf.ext
```
 args = /etc/dovecot/conf.d/dovecot-ldap.conf.ext
```

*In /etc/dovecot/conf.d/dovecot-ldap.conf.ext

```
```





# References

* https://wiki2.dovecot.org/AuthDatabase/LDAP
* https://wiki2.dovecot.org/AuthDatabase/LDAP/AuthBinds

