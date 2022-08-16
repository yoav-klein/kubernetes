
# Kubernetes The Hard Way
---

## Introduction

This project follows the original [kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way) guide, which explains
how to set up a kubernetes cluster from scratch - i.e. - manually create all the certificates,
kubeconfigs, and setup the kubernetes binaries and services on the nodes, instead of using an
installer such as kubeadm, minikube, etc.

This project is a bunch of scripts that implement the original guide in an automatic manner. The user
fills in the details about his infrastructure (i.e. node IP addresses, etc) in a JSON file,
and the scripts will go on and bootstrap a kubernetes cluster on the user's infrastructure.

## Cluster Architecture
The original guide guides you to set up a cluster with 3 controllers and 3 worker nodes.
In a multi-controller cluster, we also need a load balancer to load-balance traffic between
the controller nodes.

In our project, you can set up (virtually) as many controllers and workers you like.
If you choose to set up a multi-controller cluster, you'll need to take care of the 
load balancer your self, and just provide the IP of this load balancer.

![picture](.attachments/kthw.png =100x100)

## Project Architecture


## Prerequisites

You'll need the following infrastructure:
* At least 1 node for controllers
* At least 1 node for workers
* All the nodes should be accessible from all other nodes
* All the nodes must have a user with the same name, and in this user's home directory's `authorized_key`
  there must be a common public key, so that  you can run ssh commands on all the nodes from one of the nodes.
 
## Getting Ready

In order to get this going, you'll need to do the followings:

* Put the private key that is needed to run commands on all the nodes in a file called `kthw_key` in the root of the project
* Configure


