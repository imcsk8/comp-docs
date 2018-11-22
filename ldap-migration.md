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

### Using new configuration from fresh install

In case the OpenLDAP version is too old is better to configure from scratch instead of keeping the old config (eg. use mdb backend instead of hdb).

**Install and prepare OpenLDAP**
```
# dnf -y install openldap-servers openldap-clients
# cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
# chown -R ldap:ldap /var/lib/ldap/

```

**Set admin password**

```
# slappasswd
New password:
Re-enter new password:
{SSHA}newhashedpassword
# vi chrootpw.ldif
# specify the password generated above for "olcRootPW" section

dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}newhashedpassword

# ldapadd -Y EXTERNAL -H ldapi:/// -f chrootpw.ldif

SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={0}config,cn=config"
```

**Import schemas**

```
# ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=cosine,cn=schema,cn=config"

# ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=nis,cn=schema,cn=config"

# ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=inetorgperson,cn=schema,cn=config"
```

**Configure directory manager account**

**Generate new directory manager password**
```
# slappasswd
New password:
Re-enter new password:
{SSHA}newhashedpassword
```

**Create directory manager account and base domain**
```
# vi chdomain.ldif
# replace to your own domain name for "dc=***,dc=***" section

# specify the password generated above for "olcRootPW" section

dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
  read by dn.base="cn=Manager,dc=srv,dc=world" read by * none

dn: olcDatabase={2}mdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=srv,dc=world

dn: olcDatabase={2}mdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=srv,dc=world

dn: olcDatabase={2}mdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}xxxxxxxxxxxxxxxxxxxxxxxx

dn: olcDatabase={2}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn="cn=Manager,dc=srv,dc=world" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=srv,dc=world" write by * read

```

```
# vi basedomain.ldif 
# replace to your own domain name for "dc=***,dc=***" section

dn: dc=srv,dc=world
objectClass: top
objectClass: dcObject
objectclass: organization
o: Server World
dc: srv

dn: cn=Manager,dc=srv,dc=world
objectClass: organizationalRole
cn: Manager
description: Directory Manager

dn: ou=People,dc=srv,dc=world
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=srv,dc=world
objectClass: organizationalUnit
ou: Group


```


**Add it to the directory configuration**
```
# ldapmodify -Y EXTERNAL -H ldapi:/// -f chdomain.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={1}monitor,cn=config"

modifying entry "olcDatabase={2}mdb,cn=config"

modifying entry "olcDatabase={2}mdb,cn=config"

modifying entry "olcDatabase={2}mdb,cn=config"

modifying entry "olcDatabase={2}mdb,cn=config"

# ldapadd -x -D cn=Manager,dc=srv,dc=world -W -f basedomain.ldif

Enter LDAP Password: # directory manager's password

adding new entry "dc=srv,dc=world"

adding new entry "cn=Manager,dc=srv,dc=world"

adding new entry "ou=People,dc=srv,dc=world"

adding new entry "ou=Group,dc=srv,dc=world"


```



### Using same configuration
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
## References

* https://www.server-world.info/en/note?os=Fedora_22&p=openldap
