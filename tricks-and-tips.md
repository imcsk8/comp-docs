# Linux Tricks and Tips

## System Administration

* **Remove string with newline using sed**
```
 sed -i -e ':a' -e 'N' -e '$!ba' -e  's/string to remove\n//g' file
```

* **Check IMAP SSL connection**
```
# openssl s_client -connect imap.gmail.com:993 
```

* **Fedora Systemd /etc/passwd manual changes**

Fedora comes with a System Security Services Daemon that manage access to remote directories and authentication mechanisms, it caches /etc/passwd in the /var/lib/sss/mc/passwd file.
If you make a manual change to /etc/passwd the sssd cache must be deleted this way:

```
# systemctl stop sssd
# rm /var/lib/sss/mc/passwd
# systemctl start sssd
```

* **Run Docker as regular user**

After installing Docker:
```
# groupadd docker
# usermod -aG docker username
```

* **Letsencrypt**

Letsencrypt its a free Certificate Authority that allows us to create valid signed certificates.

Install
```
# dnf install -y certbot
```

Create certificate

```
# certbot certonly --webroot -w /var/www/example -d example.com -d www.example.com -w /var/www/thing 
```

Renew Certificates
```
# certbot renew --dry-run
```

If everything is ok:
```
# certbot renew
```

If it fails renew manually
```
# certbot certonly -d ivan.chavero.com.mx
```

*More:* https://certbot.eff.org/lets-encrypt/fedora-haproxy

* **Check SSL certificate from command line**
This is useful to avoid confusion with the web browser cache

```
echo | openssl s_client -showcerts -servername seispistos.com -connect seispistos.com:443 2>/dev/null | openssl x509 -inform pem -noout -text
```

* **HAProxy with letstencrypt certificates**

HAProxy needs the the private key and the certificates in a bundle:
```
# cd /etc/letsencrypt/live/ivan.chavero.com.mx/
# cat privkey.pem > haproxy_fullchain.pem
# cat fullchain.pem >> haproxy_fullchain.pem
# ln -s /etc/letsencrypt/live/ivan.chavero.com.mx/haproxy_fullchain.pem /etc/ssl/haproxy/ivan.chavero.com.mx.pem
```

Configure HAProxy:
In /etc/haproxy/haproxy.cfg
```
bind 10.0.0.1:443 ssl crt /etc/ssl/haproxy
```

* **Vim for go development**

On ~/.vimrc using Plug

```
call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'valloric/youcompleteme'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
" Initialize plugin system
call plug#end()

```

Install the plugins inside vim

```
:PlugInstall
```

YouCompleteMe uses a server, install it

```
$ sudo dnf install cmake gcc-c++ make python3-devel
$ cd ~/.vim/plugged/youcompleteme
$ ./install.py  --clang-completer --ts-completer --go-completer

```

* **Grow Logical Volume**

```
# lvextend -L60G /dev/fedora/root
```

*Extend to all available space*

```
lvextend -l +100%FREE /dev/fedora/root
```

* **Grow the filesystem**

*Assuming that the partition is mounted on /*

```
# xfs_growfs /
```

* **Create a Logical Volume**

```
# lvcreate -L 100G -n var fedora
```

*Set size to the rest of disk free space*

```
# lvcreate -l +100%FREE -n ceph fedora
```

* **Reduce Logical Volume**
```
# xfs_repair /dev/mapper/sotolito-var
# mount /dev/mapper/sotolito-var /mnt
# xfsdump -f var-backpu.dump /mnt
# umount /mnt
# lvreduce -L 80G /dev/mapper/sotolito-var
# mkfs.xfs -f /dev/mapper/sotolito-var
# mount /dev/mapper/sotolito-var /mnt
# xfsrestore -f var-backpu.dump /mnt
```


* **Copy ssh key to a host**

```
# ssh-copy-id 192.168.1.10
```

* **Resize qcow image**
```
qemu-img resize nice-superduper-image.qcow2 +5G
```

* **Share internet using Gnome GUI**

* https://tutorials.technology/tutorials/74-How-to-share-internet-with-Gnome-3-or-Fedora-26-also.html

* **Check loaded modules directly**

If for some reason (dracut shell?) you can't use the Linux module management utilities you 
can check your loaded modules by checking the contents of: */proc/modules*
```
# cat /proc/modules
```

* **Set Ansible host on the command line**

Just add a "," after the host name (*WTF! note very well documented*)

```
$ ansible-playbook -i hostname.com, my-playbook.yaml
```

* **Set Ansible user on the command line**

```
$ ansible-playbook -u root my-supeduperplaybook.yaml
```

* **Use podman as non root user**
This files specifies the user and group IDs that ordinary users can use, with the newuidmap
command, to configure uid mapping in a user namespace.

```
# echo ichavero:100000:65536 >> /etc/subuid
# echo ichavero:100000:65536 >> /etc/subgid
```

* **Create pods using podman and kubernetes yaml files**

```
# podman play kube yamlfile.yaml
```

* **List image registry from the command line**

```
curl -X GET -u username:password https://docker.io/v2/_catalog
```

* **Wordpress behind HAProxy SSL termination**
If the force ssl option is set in wordpress but the SSL is being terminated by HAProxy (or other reverse proxy) wordpress will check with `is_ssl()` function for the `$_SERVER['HTTPS']` entry to be `on` but since HAProxy terminates the SSL connection and communicates with the backend via plain HTTP the wordpress web server won't set this entry in the `$_SERVER` array, you have to modify `wp-config.php` to set `$_SERVER['HTTPS']` manually:

```
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')
    $_SERVER['HTTPS'] = 'on';
```

* **OpenVPN**

https://fedoraproject.org/wiki/Openvpn

** Enable LDAP authentication **

Install LDAP plugin

```
# dnf install -y openvpn-auth-ldap.x86_64
```

Configure `/etc/openvpn/auth/ldap.conf` with the proper LDAP account and DN


Add this to the config file:

```
# Enable LDAP authentication
plugin /usr/lib64/openvpn/plugins/openvpn-auth-ldap.so /etc/openvpn/auth/ldap.conf
client-cert-not-required
```

* **Limit ssh connection attempts using firewalld**
To avoid brute force attacks while using firewalld

```
# firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -p tcp --dport 22 -m state --state NEW -m recent --set
# firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 1 -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 30 --hitcount 4 -j REJECT --reject-with tcp-reset
# firewall-cmd --reload
```

If you have several ports:

```
# firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -p tcp --dport 7000:9000 -m state --state NEW -m recent --set
# firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 1 -p tcp --dport 7000:9000 -m state --state NEW -m recent --update --seconds 30 --hitcount 4 -j REJECT --reject-with tcp-reset
# firewall-cmd --reload
```

* **Podman Update**
Upgrading podman might have some caveats, if this happens it might mean that the containers have to be migrated to the next version:
To do run the `migrate` podman command for each user that has problems.
```
$ podman system migrate
```
It might be useful tu run this command in the scripts that run the podman containers.


* **Podman Cleanup**
Creating images and containers is a messy business, it's a good practice to cleanup the system to delete unused containers, pods, volumes and data.

```
$ podman system prune
```

* **Add Files to Nextcloud**

You might already have uploaded files in your Nextcloud server, to make them available in your Nextcloud instance:

Copy the files to the Nextcloud filesystem
```
# cp -rp space/* /var/www/nextcloud/data/<username>/files
```

Tell Nextcloud to reindex the files

```
# su www-data -c ./occ files:scan --path="/<username>/files"
```

* **Convert gif to mp4**
You can create your awesome animated gifs using gimp and then convert them to mp4 using ffmpeg 

```
$ ffmpeg -i animated.gif -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" video.mp4
```
