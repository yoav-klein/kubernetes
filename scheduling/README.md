
# Scheduling
---

You can control the scheduling process by several methods.
We'll demonstrate two: nodeSelector and nodeName.

## nodeSelector
In this method, we're using the `nodeSelector` pod configuration in order to tell the scheduler
on which node(s) is it possible to run the pod.

First, let's see our nodes
```
$ kubectl get nodes
```

Now, select one of the nodes, and attach a label to it, so we can use a nodeSelector to run on the node.

```
$ kubectl label nodes <node_name> special=true
```

our `nodeselector-pod.yaml` pod is configured with a nodeSelector configuration, see inside.

Now run that pod:
```
$ kubectl apply -f nodeselector-pod.yaml
```

Now if you run
```
$ kubectl get pods -o wide
```

You'll see that the pod is running on your selected node.

