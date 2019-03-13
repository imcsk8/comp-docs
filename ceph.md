# Ceph notes

## Open ports using firewalld

### Monitors
```
# firewall-cmd --zone=public --add-port=6789/tcp --permanent
# firewall-cmd --reload
```

### Rados Gateway
```
# firewall-cmd --zone=public --add-port=7480/tcp --permanent
# firewall-cmd --reload
```
