# Volumes
Volumes allow you to share data between your Pod's containers and the outer world.

We'll see here 2 types of volumes: _hostPath_ and _emptyDir_

## hostPath
hostPath type allows you to mount a directory from the containers to a local directory on the worker node
on which the Pod is running on.
So in our example, we have a simple busybox container that writes "Success!" to `/output/success.txt`.
We define a `hostPath` volume for the Pod, assigning it to `/var/data`. Then we mount the volume to the container on the path
`/output`, so when the container writes to `/output` it actually writes to `/var/data` on the host machine.

```
$ kubectl apply -f volume-pod.yaml
```

This wrote the Success message to the file.
Now see on which node that Pod ran on:
```
$ kubectl get pods -o wide
# note the node of the Pod
$ ssh <node>
$ cat /var/data/success.txt
```
You should see the "Success !" message.

## emptyDir
This kind of volume is not persistent. It creates an empty directory on the host which will live only as long as the Pod lived.
Once the Pod is deleted, it is also deleted. The use of this is to allow multiple containers on the same Pod to share data between them.

In the `shared-volume-pod.yaml` we have 2 containers, both mounting the `emptyDir` volume to different paths in the containers. The `busybox1` container 
writes to the shared volume, and the `busybox2` container reads from it.

```
$ kubectl apply -f shared-volume-pod.yaml
```

Now get the output that was written by `busybox2`:
```
$ kubectl logs shared-volume-pod -c busybox2
```

# PersistentVolumes

We have a demo here of using PersistentVolumes.

First, create a _StorageClass_
```
$ kubectl apply -f storage-class.yaml
```

Now, create a _PersistentVolume_ that references that StorageClass
```
$ kubectl apply -f my-pv.yaml
```
That PersistentVolume persists data on `/var/output` on the node that the Pod will run on.

Note that the PersistentVolume object is AVAILABLE:
```
$ kubectl get pv
```

Now we'll create a _PersistentVolumeClaim_ that matches the PersistentVolume spec, so the PersistentVolume will be 
taken by that Claim
```
$ kubectl apply -f my-pvc.yaml
```

Now check the status and see that it is in the _Bound_ state.

Now let's create a Pod to use the PersistentVolume
```
$ kubectl apply -f pv-pod.yaml

$ kubectl get pods
```

See it's in the Completed state. You can log to the node that the Pod ran on and see the data there.

Now let's see Recycle. Delete the Pod and the claim:
```
$ kubectl delete pod pv-pod
$ kubectl delete pvc my-pvc
```

Now see the state of the PersistentVolume
```
$ kubectl get pv
```

See that it's available



