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






# References

* https://wiki2.dovecot.org/AuthDatabase/LDAP
* https://wiki2.dovecot.org/AuthDatabase/LDAP/AuthBinds

