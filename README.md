fleet
=====

WIP for managing a collection of docker hosts


#Digital Ocean

##Prerequisites

* SSH access for `root` user added to ssh-agent
* SSH access for `ubuntu` user added to ssh-agent
* SSH public key to configure `ubuntu` user in `ssh_keys/authorized_keys_for_ubuntu` file
* The inventory file `docker_hosts` must have the following format

```
public_ip_address_host_1 host_id=1 other_hosts="private_ip_address_host_2 private_ip_address_host_3"
public_ip_address_host_2 host_id=2 other_hosts="private_ip_address_host_1"
public_ip_address_host_3 host_id=3 other_hosts="private_ip_address_host_1"
```

##Prepare the servers

```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --inventory-file=docker_hosts ansible-playbooks/prepare-digital-ocean-server.yml
```

##Configure the servers as docker's hosts

```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --inventory-file=docker_hosts ansible-playbooks/docker.yml
```

##Notes

* The host 1 will act as *network concentrator*, all traffic will pass through it.
* The docker service will be available in IP address 10.10.X.1, X is the `host_id`
* The containers in host X will have an IP address like 10.10.X.Y, X is the `host_id`

**ENJOY!**