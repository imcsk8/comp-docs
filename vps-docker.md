# Virtual Private Server using docker containers

Containers are very popular for microservices and their other use cases tend to be overlooked. Since containers provide isolation for Operating System Virtualization, they can be used as VPS's.

## Architecture

In order to have the best of both worlds we'll consider our container as a disposable unit having the configuration and data volumes mounted from the host filesystem.

The docker container should mount the /etc and /var as external volumes.

Our basic VPS container is going to server web apps so we'll start with this Dockerfile:

```

```

## References

* https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/container_security_guide/docker_selinux_security_policy
