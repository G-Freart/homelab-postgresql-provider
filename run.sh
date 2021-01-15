#!/bin/bash

if [ ! -d ~/.ansible/collections/ansible_collections/community/libvirt ];
then
  ansible-galaxy collection install -r collections/requirements.yaml
fi

ansible-playbook main.yaml
