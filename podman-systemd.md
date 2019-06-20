# Using podman containers with systemd

## Podman
Podman is a OCI container manager utility analogous to docker, it aims
to mimic the docker command interface but it works in a different way.

Podman has the ability to run containers as the user that runs it, this
is better than the client/server model that docker uses because the 
containers inherit the attributes of the user that runs them (docker 
runs the server as root).

## Systemd init
Systemd is more than an init system, is a suite for building Linux systems.
It's init system is declarative and uses files called units.

## Systemd units
In order to use run OCI containers as system services we'll create a systemd
unit that executes the podman command that starts the container.

TODO...

