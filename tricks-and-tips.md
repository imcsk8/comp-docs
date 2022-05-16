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

* **CentOS stream misteriously excluded packages**

For some reason that i haven't had time to check some packages are excluded, to fix this add `module_hotfixes=True` to the repo file

```
echo "module_hotfixes=True" >> /etc/yum.repos.d/CentOS-AppStream.repo
```

* **Convert vmdk image to qcow2**

```
$ qemu-img convert -f vmdk -O qcow2 WinDev2005Eval-disk1.vmdk WinDev2005Eval.VMware.qcow2
```

or 

```
$ kvm-img convert -O qcow2 WinDev2005Eval-disk1.vmdk WinDev2005Eval.VMware.qcow2
```

* **Increase uid mappings for Podman**

Systems like OpenShift use uid mappings on ranges out of the default Linux settings.


**Increase uid and gid mappings for user namespace**
```
~# echo 1001189999 > /proc/sys/user/max_user_namespaces
~# echo "youruser:100000:1001180000" >> /etc/subuid
~# echo "youruser:100000:1001180000" >> /etc/subgid
```

**Reload the uid mappings for Podman**

*as youruser*
```
~$ podman system migrate
```


* **Change cloud image password**

```

~$ virt-customize -a Fedora-Cloud-Base-33-1.2.x86_64.raw --ssh-inject root:file:~/.ssh/id_rsa.pub \
   --root-password password:prueba123 --uninstall cloud-init
```


* **SELinux relabel directories**

Don't disable SELinux!! Use it!!

If you change the mariadb datadir you have to change the security context type of the 
new directory

If your're like me get the security context type of the orignal mariadb directory:
```
# ls -Z /var/lib/mysql
system_u:object_r:mysqld_db_t:s0 aria_log.00000001  system_u:object_r:mysqld_db_t:s0 multi-master.info
```

Add the *mysqld_db_t* security context type to the new mariadb datadir
```
# chcon -R -v --type=mysqld_db_t pda_data1
# semanage fcontext -a -t mysqld_db_t "/home/pda_data1(/.*)?"
# systemctl restart mariadb
```


* **Recover from XFS (sdX): Filesystem has duplicate UUID 784265cb-5bd6-4b1a-b575-4660b5be2cdd - can't mount**
Sometimes when theres a power failure external disks with the XFS filesystem misbehave and rebooting is not an option, just ignore the UUID stuff for the session. This is temporary, the solution is to reboot the system.
```
mount -o nouuid /dev/sda1 /mnt
```


* **Increasee OOM score to avoid being killed first when the kernel runs out of memory**

/proc/<pid>/oom_score_adj allows tu increase or decrease the OOMKiller score: -1000 higest score (always use memory), 1000 lowest score (It will get killed with minimal memory usage)

```
echo -200 > /proc/5433/oom_score_adj
```
 
 * **Intel hardware acceleration**
 
 Install:
 ```
 # dnf install -y libva-utils intel-media-driver
  ```
 
 Set the LIBVA_DRIVER_NAME environment variable:

```
$ echo "LIBVA_DRIVER_NAME=iHD"  >> /etc/environment
```

Test with:
```
$ vainfo
```

* **Configure Firefox to use VAAPI acceleration**

Go to `about:config` and set:  

* `media.ffmpeg.vaapi.enabled`: **true**
* `media.navigator.mediadatadecoder_vpx_enabled`: **true**
 
* **Configure Chrome to use VAAPI acceleration**
 
Go to: `chrome://flags` and set: **Override software rendering list** to //Enabled//

* Microsoft True Type fonts:

From RPM Fustion install lpf-mscore-fonts`

```
$ lpf state
$ lpf update
```
 
 https://github.com/leamas/lpf
 
* **Read SSL certificate**
 
```
 $ openssl x509 -in /etc/ssl/nginx/self_signed.crt -text -noout
```

 * **Disable nextcloud maintenance mode**
 ```
 $ php occ maintenance:mode  --off
 ```
 
  * **Show IP address on TTY**
 
 ```
 $ echo "Current IPv4 address \4" >> /etc/issue
 ```

 * Create stereoscopic 3D image
 
 ```
  $ ffmpeg -y -i awesome_vide.mp4 -vf stereo3d=ar:arcd awesome_3d_video.mp4
 ```

 * Change a route metric
 The metric in a route is the cost of following it, the lowest the metric is the 
 preferred one.
 
 ```
 # ip route replace default via 192.168.1.1 metric 1
 ```

* Show available versions of a package
 
 ```
 $ dnf --showduplicates list php
 ```
