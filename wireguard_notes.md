# Wireguard VPN

## Installation

```bash
# dnf install -y wireguard-tools
```

## Server Configuration

### Generate key pairs
```bash
# cd /etc/wireguard
# wg genkey | tee privatekey | wg pubkey > publickey
```

### Configure the wireguard interface
```bash
# cat << EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 172.16.1.254/32
SaveConfig = true
ListenPort = 60001
PrivateKey = ---- your generated privatekey

# Client
[Peer]
PublicKey = ---- CLIENT PUBLIC KEY
AllowedIPs = 172.16.1.2/32
EOF
```

### Open Firewall Ports
```bash
# firewall-cmd --add-port=60001/udp --permanent --zone=public --permanent
# firewall-cmd --reload
```

### Import the profile to NetworkManager
```bash
# nmcli con import type wireguard file /etc/wireguard/wg0.conf
```


## Client Configuration

### Generate key pairs
```bash
# cd /etc/wireguard
# wg genkey | tee privatekey | wg pubkey > publickey
```

### Configure the wireguard interface
Configurations look almost the same with the difference that there's no `ListenPort` directive on the client and the addition of the `endpoint` directive which is the public ip:port of the wireguard server.

```bash
# cat << EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 172.16.1.2/24
PrivateKey = ---- your generated privatekey

[Peer]
PublicKey = ------ SERVER PUBLIC KEY
endpoint = SERVER_PUBLIC_IP:PORT
AllowedIPs = 172.16.1.0/24
EOF
```

### Import the profile to NetworkManager
```bash
# nmcli con import type wireguard file /etc/wireguard/wg0.conf
```

### Create Firewalld Zone

In order to keep things clean we'll create a new zone for our Wireguard VPN

**Create the zone**
```bash
# firewall-cmd  --new-zone=wireguard --permanent
```

**Remove the wireguard interface to the public zone**
```bash
# firewall-cmd  --zone=public --remove-interface=sotolito --permanent
```

**Add the wireguard interface to the zone**
```bash
# firewall-cmd  --zone=wireguard --add-interface=wg0 --permanent
```

**Allow forwarding to the zone**
```bash
# firewall-cmd --zone=wireguard --add-forward --permanent
```

**Don't forget to reload baby!!**
```bash
# firewall-cmd --reload
```


# References
* https://fedoramagazine.org/configure-wireguard-vpns-with-networkmanager/
