
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

Note that you can assign multiple nodes with that label and value, so that the pod will run on one of them.

## nodeName
In this method, we're just picking a specific node, taking its name and configuring our pod to run on that node.

First, list your nodes and pick one:
```
$ kubectl get nodes
```

Our `nodename-pod.yaml` pod spec is configured to run on a specific node (change the name to a valid node name)

Run it:
```
$ kubectl apply -f nodename-pod.yaml
```


