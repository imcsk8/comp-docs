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
Plug 'powerline/powerline'


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
