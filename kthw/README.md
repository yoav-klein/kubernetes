
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

<img src=".attachments/kthw.png" width="800">

### Controller Nodes
on each controller node, we have the following components:
* etcd
* kube-apiserver
* kube-scheduler
* kube-controller-manager

### Worker Nodes
on each worker node, we have the following componets:
* containerd
* kubelet
* kube-proxy

## Project Architecture

The project is built so that for each step in the bootstraping
process there's a directory containing all the files needed to perform this step.
So for example the `certificates` directory contains everything's needed to create
all the certificates needed in order to run our cluster.

The steps for bootstraping the cluster are:
1. Generate certificates
2. Generate kubeconfigs
3. Install and run etcd on controller nodes
4. Install and run kubernetes components on controller nodes
5. Install and run a container runtime and kubernetes components on worker nodes


## Usage

In order to understand how to use the project and set up a cluster, refer to the User Guide page.

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


