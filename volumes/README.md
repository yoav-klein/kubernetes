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
