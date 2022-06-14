# emptyDir
---

The `emptyDir` type of volume is not persistent. It creates a volume on the node where the pod is running, and 
is deleted once the pod is deleted. The use of it is to share data across containers in the same pod.

In this example, we have 2 containers, both mounting the `emptyDir` volume. the `writer` container writes to the volume, 
and the `reader` container reads from it.

```
$ kubectl apply -f emptydir-pod.yaml
```

Now see the logs of the reader container:
```
$ kubectl logs emptydir-pod -c reader 
```
