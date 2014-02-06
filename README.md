fleet
=====

WIP for managing a collection of docker hosts


#Vagrant

##Prerequisites

* VM must be connected using a private network
* Every hostname must resolve to 127.0.0.1 (adding `127.0.0.1 hostX` do the work)
* The inventory file `vagrant_hosts` must include the ssh port forwarded in Vagrantfile

```
host1 ansible_ssh_port=2251 host_id=1 other_hosts="192.168.50.102 192.168.50.103"
host2 ansible_ssh_port=2252 host_id=2 other_hosts="192.168.50.101"
host3 ansible_ssh_port=2253 host_id=3 other_hosts="192.168.50.101"
```

##Configure the servers as docker's hosts

```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --user=vagrant --private-key=~/.vagrant.d/insecure_private_key --inventory-file=vagrant_hosts ansible-playbooks/docker.yml
```


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
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --user=ubuntu --inventory-file=docker_hosts ansible-playbooks/docker.yml
```

##Notes

* The host 1 will act as *network concentrator*, all traffic will pass through it.
* The docker service will be available in IP address 10.10.X.1, X is the `host_id`
* The containers in host X will have an IP address like 10.10.X.Y, X is the `host_id`

**ENJOY!**