# Ops Tricks and Tips

_K8s, OpenShift, PaaS, IaaS, WtfaaS_

## OpenShift

* **Add user to current project**
```
$ oc adm policy add-role-to-user edit username
```

* **Get content of a pull secret**

```
oc get secret/pullsecret  -n my-namespace -o go-template --template='{{index .data ".dockerconfigjson"}}' | base64 -d
```

## References
* https://cookbook.openshift.org
