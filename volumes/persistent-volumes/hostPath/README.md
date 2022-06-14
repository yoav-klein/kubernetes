# hostPath type
---

The `hostPath` type of PersistentVolume uses, as the name implies, the filesystem of the host.

This is basically not a recommended type of PersistentVolume.

In this example, we create a PersistentVolume and a corresponding PersistentVolumeClaim. Then,
we run a `writer-pod` which will write to the mounted PersistentVolume.

Then, we'll use the `reader-pod` to read this information. We'll see that if the reader-pod will not run
on the same node as the writer-pod, it won't be able to read anything, since the writer-pod wrote it
on the disk of the specific node it ran on.

## Usage
---
Create the PersistentVolume and PersistentVolumeClaims:
```
$ kubectl apply -f hostpath-pv.yaml
$ kubectl apply -f hostpath-pvc.yaml
```

Now, create run the `writer-pod`
```
$ kubectl apply -f writer-pod.yaml
```

This writer-pod wrote to `/output/success.txt`, and is now at a `Completed` state.

Now let's run the `reader-pod` to read it

```
$ kubectl apply -f reader-pod.yaml
```

This pod `cat`ed this file to stdout. Now let's use `kubectl logs` to read it
```
$ kubectl logs reader-pod
```

NOTE that if they didn't run on the same node, the reader-pod כfails!

You can check this:
```
$ kubectl get pods -owide
```
