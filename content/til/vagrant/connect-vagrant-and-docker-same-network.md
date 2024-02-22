---
title: "Connect Vagrant VM and Docker container on same network"
date: 2023-07-14
lastmod: 2023-07-14
draft: false
toc: false
tags:
- vagrant
- docker
- networking
---

In order to allow a Vagrant VM to be reachable from a Docker container on the
same host system, and vice versa, we need to create a Docker network and
configure the Vagrant VM to use the same bridge network.

Firstly, create a Docker network `foo`:

```bash
$ docker network create -d bridge --gateway=10.0.0.1 --subnet=10.0.0.0/24 foo
```

or using `docker-compose`:

```yml
services:
  ...
networks:
  foo:
    ipam:
      config
        - subnet: "10.0.0.0/24"
          gateway: "10.0.0.1"
```

This will create a bridge with name `br-[network_id]` on the host machine.

Next, in the `Vagrantfile`, configure the VM to use the same bridge device on a
public network:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bullseye64"
  config.vm.network "public_network", ip: "10.0.0.2", bridge: "br-[network_id]"
end
```

>If you are using the [libvirt
>provider](https://vagrant-libvirt.github.io/vagrant-libvirt/configuration.html),
>the `:dev` clause must be used instead of `:bridge`.

Finally, start the Vagrant VM and docker container. Ensure that both systems are
reachable from each other:

```bash
$ vagrant up
$ docker run -it --network=foo alpine ping -c2 10.0.0.1
# or docker-compose up -d
```

## References
- [Access Vagrant VMs from Docker container](https://stackoverflow.com/questions/48507357/access-vagrant-vms-from-inside-docker-container)
