# Container registry

## Start registry
TODO: Add SSL
```
#!/bin/bash

podman run --name cfdi-container-registry \
-p 5000:5000 \
--restart=always \
-v /srv/registry/data:/var/lib/registry:Z \
-v /srv/registry/auth:/auth:Z \
-e "REGISTRY_AUTH=htpasswd" \
-e "REGISTRY_AUTH_HTPASSWD_REALM=CFDI Realm" \
-e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
-e REGISTRY_COMPATIBILITY_SCHEMA1_ENABLED=true \
-d \
docker.io/library/registry:
```
## Create user or change password

```
htpasswd -B  /srv/registry/auth/htpasswd myuser
```
Use `-B` to force bcrypt encryption of the password, whithout this switch passwords are going to be rejected.

###
