# Resource Requests and Resource Limits

## Resource Requests
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


