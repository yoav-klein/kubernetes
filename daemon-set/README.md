
# DaemonSets

A DaemonSet is a Kubernetes object which will create a copy of a pod on each node in the cluster.
It is part of the `apps/v1` apiVersion.

We have a `daemon-set.yaml` that defines a DaemonSet.
Go ahead and run it:

```
$ kubectl apply -f daemon-set.yaml
```

See it live:
```
$ kubectl get daemonsets
```

You can also see the pods:
```
$ kubectl get pods -o wide
```

Note that by default, a DaemonSet will not create a copy on the master node.

