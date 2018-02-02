# Ansible Playbook Docker Image

Docker Image of Ansible for executing ansible-playbook command against an externally mounted set of Ansible playbooks. Based on [philm/ansible_playbook](https://github.com/philm/ansible_playbook)

## Features

This container has some enhancements over the original basic container:

* Prevent Ansible running as root inside the container, with all the risks that entails.
* Run as the current user, avoiding permission problems on generated files and playbooks
* Allow testing against local Vagrant boxes (see **Vagrant notes**)

## Build

```
docker build -t philayres/docker-ansible-playbook .
```

### Test

```
$ docker run --name docker-ansible-playbook --rm philayres/docker-ansible-playbook --version

docker-ansible-playbook 2.3.0.0
  config file =
  configured module search path = [u'/opt/ansible/library']
  python version = 2.7.13 (default, Apr 20 2017, 12:13:37) [GCC 6.3.0]
```

## Running Ansible Playbook

Copy `docker-ansible-playbook.sh` to the root directory of your playbook.

```
# This can be omitted if not using Vagrant (or add them at the top of the docker-ansible-playbook.sh if preferred)
VAGRANT_IP=192.168.1.12
VAGRANT_HOSTNAME=vagrant-box-hostname
./docker-ansible-playbook.sh <playbook args>

# for example

./docker-ansible-playbook.sh playbook-zeus.yml -vvvv -l zeus-webapp-vm-test --vault-password-file=.vault-password
```

## Get a bash prompt inside the Docker container

To enter the docker environment to test for ssh connections, etc, use the following:

```
# exclude the environment variables if not using Vagrant
VAGRANT_IP=192.168.1.12
VAGRANT_HOSTNAME=vagrant-box-hostname
./docker-bash.sh
```


## To run Ansible Vault

```
docker run --rm -it -v $(pwd):/ansible/playbooks --entrypoint ansible-vault \
  philayres/docker-ansible-playbook encrypt FILENAME
```

## Vagrant notes

In order to make vagrant accept remote SSH connections, several things have to be done.

The `Vagrantfile` requires an entry to allow the box to join a public network.

    config.vm.network "public_network", use_dhcp_assigned_default_route: true

This should be sufficient to expose the service to the machine.

The file `ssh-config-docker` must be added to the playbook root directory. Replace the two
**vagrant-box-hostname** entries with the vagrant box hostname. This file controls
SSH connection and authentication to the box.

To ensure docker containers can access the host's network, test with:

    docker run --rm -it --entrypoint ping philayres/docker-ansible-playbook -c4 google.com

If that doesn't return, add the following entry to the docker configuration
(`/etc/docker/daemon.json` - which may not already exist):

    {
    	"dns": ["8.8.8.8", "8.8.4.4"]
    }

Then restart the docker daemon:

    sudo service docker restart

Retest the docker ping.

    docker run --rm -it alpine ping -c4 google.com

No test the Ansible docker container can ping the vagrant box:

    docker run --rm -it --entrypoint ping philayres/docker-ansible-playbook -c4 <vagrant-box-hostname>
