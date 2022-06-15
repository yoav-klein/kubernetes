

# NFS Persistent Volume
---

This example demonstrate the use of NFS as a Persistent Volume in Kubernetes.

Refer to this example in GitHub:
https://github.com/kubernetes/examples/tree/master/staging/volumes/nfs

 
## NFS Server
---
First, some introduction about NFS server. We use a kernel-level server, that can be installed
with `apt-get install nfs-kernel-server`.

The NFS server runs the following services:
* nfs (port 2049)
* rpcbind (port 111)
* statd (custom port)
* mountd (custom port)

After you've installed it on a machine, you can now mount a directory from another machine.
Learn deeper about this if you need.

In order for it to run, you'll need to load the kernel modules: `nfs`, `nfsd`.

In this example, we run the NFS server in a pod, and expose it as a service. The directory
that the NFS exposes is some directory in the host where the pod runs. We need to create
this directory before-hand and change its permissions.

We use a container image that contains a NFS server. For reference: `https://github.com/yoav-klein/docker-nfs-server` 


## Running the example
---

### Some required setup

First, we'll need to create the exported directory on each node machine, since we don't know
where the pod will run. We also need to load the kernel modules required to run a NFS server.

You also need to install `nfs-common` on each node

On each node machine, run the following commands:

```
$ sudo apt-get install nfs-common
$ sudo mkdir /mnt/nfs-export
$ sudo chown nobody:nogroup /mnt/nfs-export
$ sudo chmod 777 /mnt/nfs-export
$ sudo modprobe nfs nfsd
```

### Run the NFS server
---
Now, create the nfs-server pod and service:
```
$ kubectl apply -f nfs-server-pod.yaml
$ kubectl apply -f nfs-server-service.yaml
```

### Create a PersistentVolume and PersistentVolumeClaim
---
After we have a running NFS server exposed as a service, we create a `PersistentVolume`
and a `PersistentVolumeClaim`.

First, note the IP of the nfs-server service:
```
$ kubectl get svc nfs-server
```

Write this IP in the `.spec.nfs.server` field in the `nfs-pv.yaml` file.

create the PV and PVC:
```
$ kubectl apply -f nfs-pv.yaml
$ kubectl apply -f nfs-pvc.yaml
```

### Create the pods that use the volume
---

In this example, we create a pod that updates the content of a web page, and another
pod that serves this page via HTTP.

Create the `update-content-pod`:
```
$ kubectl apply -f update-content-pod.yaml
```

Now create the `web-server-pod` and the service with which you'll access the HTTP server:
```
$ kubectl apply -f web-server-pod.yaml
$ kubectl apply -f web-server-service.yaml
```


Now take the IP of the `web-server` service, and curl to it:
```
$ curl <web-server-ClusterIP>
```

