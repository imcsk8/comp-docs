# Dovecot IMAP with LDAP

This document details how to configure dovecot with LDAP in Fedora

## Install Dovecot and dependencies

**Install Dovecot and sasl support**

```
# dnf install -y cyrus-sasl cyrus-sasl-ldap dovecot
```

## Configure Authentication

We'll use AuthBinds, this way the LDAP server takes care of password authentication.









# References

* https://wiki2.dovecot.org/AuthDatabase/LDAP
* https://wiki2.dovecot.org/AuthDatabase/LDAP/AuthBinds

