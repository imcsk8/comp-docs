# Ceph notes

# Installation using Ceph Ansible

### OSDs

Ceph Ansible uses the `lvm` scenario which requires disks with clean partition tables.

* To clean parition tables from `/dev/sdb`:

```
# wipefs -a  -f  /dev/sdb
```

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
