# Create CentOS Custo Image

I wrote a shell script to create custom images but it was a hassle because I had to modify the script almos each time I created an image. 
That's why I switched to osbuild.

## Install OSBuild

```bash
# dnf install -y lorax lorax-composer lorax-templates-generic \
  composer-cli osbuild cockpit-composer weldr-client
```

## Enable services

```bash
# systemctl enable osbuild-composer.socket
# systemctl start osbuild-composer.socket
```

## Add repos

### EPEL

```
cat <<EOF > epel.ini
check_gpg = true
check_repogpg = true
check_ssl = true
id = "EPEL9"
name = "EPEL9"
rhsm = false
system = false
type = "yum-baseurl"
url = "https://mirrors.kernel.org/fedora-epel/9/Everything/x86_64/"
EOF
```

Add the repo to composer

```bash
# composer-cli sources add epel.ini
```

### ELRepo

```
cat <<EOF > elrepo.ini
check_gpg = true
check_repogpg = true
check_ssl = true
id = "ELRepo"
name = "ELRepo"
rhsm = false
system = false
type = "yum-baseurl"
url = "http://elrepo.org/linux/elrepo/el9/$basearch/"
EOF
```

Add the repo to composer

```bash
# composer-cli sources add elrepo.ini
```

### Sotolito

```
cat <<EOF > sotolito.ini
check_gpg = true
check_repogpg = true
check_ssl = true
id = "ELRepo"
name = "ELRepo"
rhsm = false
system = false
type = "yum-baseurl"
url = "http://repos.sotolitolabs.com/linux/sotolito/el9/$basearch/"
EOF
```

Add the repo to composer

```bash
# composer-cli sources add sotolito.ini
```


# References

* https://major.io/p/build-custom-centos-stream-cloud-image/
