#!/bin/bash
ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook --user=vagrant \
                 --private-key=~/.vagrant.d/insecure_private_key \
                 --inventory-file=inventory-vagrant ansible-playbooks/docker.yml \
                 -v "$@"

