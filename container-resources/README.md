# Resource Requests and Resource Limits

## Too big request
In the `big-request-pod.yaml` we request a lot of CPU.
Try to run this pod:

```
$ kubectl apply -f big-request-pod.yaml
``` 
But since we don't have the much resources on any of our nodes, the pod
will be on the pending state forever
```
$ kubectl get pods
```

## Reasonable request and limits
The `resource-pod.yaml` defines a pod which requests for a reasonable amount of CPU and memory,
and also limits the use of CPU and memory for this container. If the container process exceeds these limits,
behaviour will vary depending on the container runtime.

```
$ kubectl apply -f resource-pod.yaml
$ kubectl get pods
```

You can see that the pod is running.
