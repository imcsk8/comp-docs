# OpenLDAP Migration

## Before the upgrade
Backup the config and user databases:

```
# mkdir /etc/openldap/backup
# cd /etc/openldap/backup
# slapcat -n 0 -l config.ldif
# slapcat -n 1 -l data.ldif
```

## After the upgrade
```
# cd /var/lib
# mv openldap-data openldap-data.bak
# cp openldap-data.bak/DB_CONFIG openldap-data/.
# chown -R ldap:ldap openldap-data
# restorecon -R -v /var/lib/openldap-data   #might not be needed
# cd /etc/openldap/backup
# slapadd -n 0 -F /etc/openldap/slapd.d -f config.ldif
# slapadd -n 1 -F /etc/openldap/slapd.d -f data.ldif -b 'o=example.com'
# systemctl start slapd

```

Be happy
