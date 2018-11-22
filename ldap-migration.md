# OpenLDAP Migration

## Before the upgrade
Backup the config and user databases:

```
# mkdir /etc/openldap/backup
# cd /etc/openldap/backup
# slapcat -n 0 -l config.ldif
# slapcat -n 1 -l data.ldif
```



## Upgrade

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

#### Configure directory manager account

**Generate new directory manager password**
```
# slappasswd
New password:
Re-enter new password:
{SSHA}newhashedpassword
```

**Create directory manager account**
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

**Create base domain and organizational units**

Add here the organizational units that you're going to use

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

#### Configure TLS

**Create SSL Certificates**

*This will create a new self signed certificate*

```
# cd /etc/pki/tls/certs 
# openssl req  -nodes -new -x509  -keyout ldap-server.key -out ldap-server.cert
Generating a RSA private key
..................................+++++
.........+++++
writing new private key to 'ldap-server.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:MX
State or Province Name (full name) []:Chihuahua
Locality Name (eg, city) [Default City]:Chihuahua
Organization Name (eg, company) [Default Company Ltd]:SotolitoLabs
Organizational Unit Name (eg, section) []:sotolitolabs
Common Name (eg, your name or your server's hostname) []:SotolitoLabs
Email Address []:info@sotolitolabs.com

```

**Configure OpenLDAP for TLS**

Copy Self signed certificate and key to OpenLDAP certificate location
```
# mkdir /etc/openldap/certs/ 
# cp /etc/pki/tls/certs/ldap-server.* /etc/openldap/certs/.
# chown -R ldap:ldap /etc/openldap/certs
```

**Create TLS directory entry**

```
# vi tls.ldif
# create new

dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/openldap/certs/ldap-server.crt
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/openldap/certs/ldap-server.key

# ldapmodify -Y EXTERNAL -H ldapi:/// -f tls.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "cn=config"

```

**Restart OpenLDAP**

```
# systemctl restart slapd 
```

**Restore entries**
```
# ldapadd -vx -D 'dc=srv,dc=world' -w adminpassword -f BACKUP.ldif
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
