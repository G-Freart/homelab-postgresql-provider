# homelab-kubernetes-provider

This ansible repo allow the provisioning of a postgresql HA cluster running inside a set of KVM VMs.
Settings configuration are done using files from the folder /vars.

As i'm in the mindset to automate the creation of my k8s cluster and apps installation, it does not
allow to modify the postgresql HA topology (number of node) whenever the cluster has been configured.

This repo is intended for my home study and was not created with a production mode mindset. Ansible 
files could be improved to avoid some cut/paste using legacy task from external file, etc.

Moreover in production, every component must have SSL certificates configured ! 

ETCD are installed in a HA topology on nodes and need to have a quorum on N/2 + 1 node available.

Techno used are :
* ansible with jinja2
* terraform
* shell script
* keepalived (multiple VIP using vrrp)
* haproxy
* patroni
* postgresql

The vars/default-settings.yaml allow to define the cluster name to create, the VM base settings as timezone, local, technical user, ...

The vars/clusters.yaml file is the one to use in order to define wished clusters :

``` yaml
# ------------------------------------------------------------------------------------------ #
#                                                                                            #
#                Copyright (c) 2021 - Gilles Freart. All right reserved                      #
#                                                                                            #
#  Licensed under the MIT License. See LICENSE in the project root for license information.  #
#                                                                                            #
# ------------------------------------------------------------------------------------------ #

#
# Within this file, you can define your cluster definition
#
definition:

  "sagittarius":

    guest_os:           'Ubuntu 20.04'

    nodes:
      vms:              3
      vcpu:             4
      mem:              16
      disk:             60

    load_balancers:
      vms:              2
      vcpu:             1
      mem:              4
      disk:             30

      vrrp:

        internal:
          iface:        ens3
          route_id:     3
          vip:          192.168.1.3/24

        external:
          iface:        ens4
          route_id:     104
          vip:          192.168.0.104/24
          bridge:       host-bridge
      
    network:
      iface:            ens3
      network_cidr:     192.168.1.0/24
      domain:           homelab
      bridge:           homelab
```

In this file, sagittarius is the name of the cluster.

Guest OS could have one of the following value :
* Ubuntu 20.04
* Ubuntu 20.10
* CentOS 7
* CentOS 8 Stream

For each VMs, settings are :
* vms : the count of VMs to provision
* vcpu : the count of virtual cpu to associate to the related VM
* mem: the RAM (in gigabyte) to associate to the related VM
* disk : the disk size (in gigabyte) to associate to the related VM

When more than one load balancer is defined, one VIP will be configured between each load balancer node. This VIP is configured
using settings put under 'internal' tag. More over, an 'external' could be also configured which allow you to access your cluster
from outside of it, using the setted KVM  'bridge'

The network part of the file allow you to customize either the KVM network or the K8S network :
* 'iface' must contains the name of the interface created during the terraform process of the VM provisionning :
  * eth0 whenever the guest operating system is a red hat based
  * ens3 whenever the guest operating system is a ubuntu based
* 'network_cidr' must contains the wished cidr of the KVM network which will be created using the given 'bridge' name.
* 'domain' contains the network domain towhich all VMs belong

A set of test cluster definition could be found inside the folder /vars/testlab_samples


Have fun with this repo!
