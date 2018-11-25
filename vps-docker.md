# Virtual Private Server using docker containers

Containers are very popular for microservices and their other use cases tend to be overlooked. Since containers provide isolation for Operating System Virtualization, they can be used as VPS's.

## Architecture

In order to have the best of both worlds we'll consider our container as a disposable unit having the configuration and data volumes mounted from the host filesystem.

Our basic VPS container is going to server web apps so we'll start with this Dockerfile:

```

```

