# SASLauth + LDAP in Fedora
## Install Cyrus-SASL
```
# dnf install -y cyrus-sasl cyrus-sasl-ldap
```

## Configure SASL LDAP

*In /etc/sysconfig/saslauthd

```
MECH=ldap
```

**Create /etc/saslauthd.conf**

```
ldap_bind_dn: cn=admin, dc=example, dc=com, dc=mx
ldap_password: admin_user_ldap_pass
ldap_servers: ldap://localhost/
#ldap_auth_method: custom
#ldap_auth_method: fastbind
ldap_search_base: dc=example, dc=com, dc=mx
ldap_filter: mail=%u
#In Case TLS is needed
#ldap_tls_check_peer: yes
#ldap_tls_cacert_file: /usr/share/ssl/certs/ca.crt
#ldap_tls_cacert_dir: /usr/share/ssl/certs
#ldap_tls_cert: /usr/share/ssl/certs/saslauthd.crt
#ldap_tls_key: /usr/share/ssl/private/saslauthd.key
```

## Test 

```
# testsaslauthd -u user@example.com -p password
0: OK "Success."
```

## References
TODO
