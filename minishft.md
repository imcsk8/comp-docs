# Testing OpenShift with minishift on Fedora

Minishift is a fork of minikube focues on provisioning OpenShift locally by running a single node
OpenShift inside a VM.

## Prerequisites

**Install KVM**

```
# dnf install libvirt qemu-kvm
# systemctl enable libvirtd
# systemctl start libvirtd
```

**Prepare user**

```
# usermod -a -G libvirt myuser
```

**Login as "myuser" or update user groups**

```
$ newgrp libvirt
```

**Install the KVM driver for docker machine**

*This is just plain wrong, Fedora should package this puppy*

```
# curl -L https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.10.0/docker-machine-driver-kvm-centos7 -o /usr/local/bin/docker-machine-driver-kvm
# chmod +x /usr/local/bin/docker-machine-driver-kvm
```

## Install Minishift

*This also should be packaged*


**Download and install from the website like a caveman**

```
# cd /usr/src
# curl -L https://github.com/minishift/minishift/releases/download/v1.30.0/minishift-1.30.0-linux-amd64.tgz -o minishift-1.30.0-linux-amd64.tgz
# cd /usr/local
# tar -zxvf /usr/src/minishift/minishift-1.30.0-linux-amd64.tgz
# ln -s minishift-1.30.0-linux-amd64 minishift
# export PATH=$PATH:/usr/local/minishift
```

## Start Minishift

```
# minishift start 
-- Starting profile 'minishift'
-- Check if deprecated options are used ... OK
-- Checking if https://github.com is reachable ... OK
-- Checking if requested OpenShift version 'v3.11.0' is valid ... OK
-- Checking if requested OpenShift version 'v3.11.0' is supported ... OK
-- Checking if requested hypervisor 'kvm' is supported on this platform ... OK
-- Checking if KVM driver is installed ... 
   Driver is available at /usr/local/bin/docker-machine-driver-kvm ... 
   Checking driver binary is executable ... OK
-- Checking if Libvirt is installed ... OK
-- Checking if Libvirt default network is present ... OK
-- Checking if Libvirt default network is active ... OK
-- Checking the ISO URL ... OK
-- Downloading OpenShift binary 'oc' version 'v3.11.0'
 53.69 MiB / 53.89 MiB [==========================================================================================================================================================]  99.63% 0s 53.89 MiB / 53.89 MiB [==========================================================================================================================================================] 100.00% 0sOK
-- Checking if provided oc flags are supported ... OK
-- Starting the OpenShift cluster using 'kvm' hypervisor ...
```
<details><summary>Expand output</summary>

```
 -- Minishift VM will be configured with ...
   Memory:    4 GB
   vCPUs :    2
   Disk size: 20 GB

   Downloading ISO 'https://github.com/minishift/minishift-centos-iso/releases/download/v1.14.0/minishift-centos7.iso'
 355.00 MiB / 355.00 MiB [========================================================================================================================================================] 100.00% 0s
-- Starting Minishift VM .......................... OK
-- Checking for IP address ... OK
-- Checking for nameservers ... OK
-- Checking if external host is reachable from the Minishift VM ... 
   Pinging 8.8.8.8 ... OK
-- Checking HTTP connectivity from the VM ... 
   Retrieving http://minishift.io/index.html ... OK
-- Checking if persistent storage volume is mounted ... OK
-- Checking available disk space ... 1% used OK
-- Writing current configuration for static assignment of IP address ... WARN
   Importing 'openshift/origin-control-plane:v3.11.0'  CACHE MISS
   Importing 'openshift/origin-docker-registry:v3.11.0'  CACHE MISS
   Importing 'openshift/origin-haproxy-router:v3.11.0'  CACHE MISS
-- OpenShift cluster will be configured with ...
   Version: v3.11.0
-- Pulling the OpenShift Container Image ............................... OK
-- Copying oc binary from the OpenShift container image to VM ... OK
-- Starting OpenShift cluster ..........................................................................................
Getting a Docker client ...
Checking if image openshift/origin-control-plane:v3.11.0 is available ...
Pulling image openshift/origin-cli:v3.11.0
E0122 20:31:15.085794    4490 helper.go:173] Reading docker config from /home/docker/.docker/config.json failed: open /home/docker/.docker/config.json: no such file or directory, will attempt to pull image docker.io/openshift/origin-cli:v3.11.0 anonymously
Image pull complete
Pulling image openshift/origin-node:v3.11.0
E0122 20:31:17.776782    4490 helper.go:173] Reading docker config from /home/docker/.docker/config.json failed: open /home/docker/.docker/config.json: no such file or directory, will attempt to pull image docker.io/openshift/origin-node:v3.11.0 anonymously
Pulled 5/6 layers, 85% complete
Pulled 6/6 layers, 100% complete
Extracting
Image pull complete
Checking type of volume mount ...
Determining server IP ...
Using public hostname IP 192.168.42.111 as the host IP
Checking if OpenShift is already running ...
Checking for supported Docker version (=>1.22) ...
Checking if insecured registry is configured properly in Docker ...
Checking if required ports are available ...
Checking if OpenShift client is configured properly ...
Checking if image openshift/origin-control-plane:v3.11.0 is available ...
Starting OpenShift using openshift/origin-control-plane:v3.11.0 ...
I0122 20:31:58.036945    4490 config.go:40] Running "create-master-config"
I0122 20:32:02.142213    4490 config.go:46] Running "create-node-config"
I0122 20:32:04.489454    4490 flags.go:30] Running "create-kubelet-flags"
I0122 20:32:05.583614    4490 run_kubelet.go:49] Running "start-kubelet"
I0122 20:32:06.062938    4490 run_self_hosted.go:181] Waiting for the kube-apiserver to be ready ...
I0122 20:34:02.134439    4490 interface.go:26] Installing "kube-proxy" ...
I0122 20:34:02.135776    4490 interface.go:26] Installing "kube-dns" ...
I0122 20:34:02.135794    4490 interface.go:26] Installing "openshift-service-cert-signer-operator" ...
I0122 20:34:02.135804    4490 interface.go:26] Installing "openshift-apiserver" ...
I0122 20:34:02.135896    4490 apply_template.go:81] Installing "openshift-apiserver"
I0122 20:34:02.136183    4490 apply_template.go:81] Installing "kube-dns"
I0122 20:34:02.137819    4490 apply_template.go:81] Installing "kube-proxy"
I0122 20:34:02.138787    4490 apply_template.go:81] Installing "openshift-service-cert-signer-operator"
I0122 20:35:02.611956    4490 interface.go:41] Finished installing "kube-proxy" "kube-dns" "openshift-service-cert-signer-operator" "openshift-apiserver"
I0122 20:38:44.666816    4490 run_self_hosted.go:242] openshift-apiserver available
I0122 20:38:44.667810    4490 interface.go:26] Installing "openshift-controller-manager" ...
I0122 20:38:44.667849    4490 apply_template.go:81] Installing "openshift-controller-manager"
I0122 20:38:50.796216    4490 interface.go:41] Finished installing "openshift-controller-manager"
Adding default OAuthClient redirect URIs ...
Adding centos-imagestreams ...
Adding registry ...
Adding sample-templates ...
Adding persistent-volumes ...
Adding router ...
Adding web-console ...
I0122 20:38:50.885797    4490 interface.go:26] Installing "centos-imagestreams" ...
I0122 20:38:50.885826    4490 interface.go:26] Installing "openshift-image-registry" ...
I0122 20:38:50.885838    4490 interface.go:26] Installing "sample-templates" ...
I0122 20:38:50.885848    4490 interface.go:26] Installing "persistent-volumes" ...
I0122 20:38:50.885859    4490 interface.go:26] Installing "openshift-router" ...
I0122 20:38:50.885882    4490 interface.go:26] Installing "openshift-web-console-operator" ...
I0122 20:38:50.886615    4490 apply_template.go:81] Installing "openshift-web-console-operator"
I0122 20:38:50.887037    4490 apply_list.go:67] Installing "centos-imagestreams"
I0122 20:38:50.888080    4490 interface.go:26] Installing "sample-templates/mysql" ...
I0122 20:38:50.888100    4490 interface.go:26] Installing "sample-templates/cakephp quickstart" ...
I0122 20:38:50.888110    4490 interface.go:26] Installing "sample-templates/dancer quickstart" ...
I0122 20:38:50.888118    4490 interface.go:26] Installing "sample-templates/rails quickstart" ...
I0122 20:38:50.888126    4490 interface.go:26] Installing "sample-templates/sample pipeline" ...
I0122 20:38:50.888135    4490 interface.go:26] Installing "sample-templates/jenkins pipeline ephemeral" ...
I0122 20:38:50.888143    4490 interface.go:26] Installing "sample-templates/mongodb" ...
I0122 20:38:50.888151    4490 interface.go:26] Installing "sample-templates/mariadb" ...
I0122 20:38:50.888159    4490 interface.go:26] Installing "sample-templates/postgresql" ...
I0122 20:38:50.888167    4490 interface.go:26] Installing "sample-templates/django quickstart" ...
I0122 20:38:50.888176    4490 interface.go:26] Installing "sample-templates/nodejs quickstart" ...
I0122 20:38:50.888266    4490 apply_list.go:67] Installing "sample-templates/nodejs quickstart"
I0122 20:38:50.890184    4490 apply_list.go:67] Installing "sample-templates/mysql"
I0122 20:38:50.890535    4490 apply_list.go:67] Installing "sample-templates/cakephp quickstart"
I0122 20:38:50.890672    4490 apply_list.go:67] Installing "sample-templates/dancer quickstart"
I0122 20:38:50.890806    4490 apply_list.go:67] Installing "sample-templates/rails quickstart"
I0122 20:38:50.891029    4490 apply_list.go:67] Installing "sample-templates/sample pipeline"
I0122 20:38:50.891174    4490 apply_list.go:67] Installing "sample-templates/jenkins pipeline ephemeral"
I0122 20:38:50.891313    4490 apply_list.go:67] Installing "sample-templates/mongodb"
I0122 20:38:50.891446    4490 apply_list.go:67] Installing "sample-templates/mariadb"
I0122 20:38:50.896036    4490 apply_list.go:67] Installing "sample-templates/postgresql"
I0122 20:38:50.897072    4490 apply_list.go:67] Installing "sample-templates/django quickstart"
I0122 20:39:19.781212    4490 interface.go:41] Finished installing "sample-templates/mysql" "sample-templates/cakephp quickstart" "sample-templates/dancer quickstart" "sample-templates/rails quickstart" "sample-templates/sample pipeline" "sample-templates/jenkins pipeline ephemeral" "sample-templates/mongodb" "sample-templates/mariadb" "sample-templates/postgresql" "sample-templates/django quickstart" "sample-templates/nodejs quickstart"
I0122 20:40:07.593498    4490 interface.go:41] Finished installing "centos-imagestreams" "openshift-image-registry" "sample-templates" "persistent-volumes" "openshift-router" "openshift-web-console-operator"
Login to server ...
Creating initial project "myproject" ...
Server Information ...
OpenShift server started.
```

</details>

```
The server is accessible via web console at:
    https://192.168.42.111:8443/console

You are logged in as:
    User:     developer
    Password: <any value>

To login as administrator:
    oc login -u system:admin


-- Exporting of OpenShift images is occuring in background process with pid 8161.

```

## Get the oc binary

```
# minishift oc-env
export PATH="/root/.minishift/cache/oc/v3.11.0/linux:$PATH"
# Run this command to configure your shell:
# eval $(minishift oc-env)

```

## External access

I have a remote lab with access to the 8081 port, configure HAProxy serving the OpenShift console

In /etc/haproxy/haproxy.cfg

```

```







## References

* https://docs.okd.io/latest/minishift/getting-started/index.html
* https://github.com/minishift/minishift
