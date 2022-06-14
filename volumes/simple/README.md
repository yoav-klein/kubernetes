# Simple example
---

this is a simple example of a pod that uses a `hostPath` volume

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


