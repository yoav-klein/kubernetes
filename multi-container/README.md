
# Multi Container Pods

You can run multiple container within your pod. Although not considered a best practice, that 
can be useful in some use cases.

## Simple example
The `multi-container-pod.yaml` defines a pod with 3 containers.
Just run it:

```
$ kubectl apply -f multi-container-pod.yaml
```

Now view the pod
```
$ kubectl get pods

~/kubernetes/multi-container$ kubectl get pods
NAME                  READY   STATUS              RESTARTS   AGE
multi-container-pod   0/3     ContainerCreating   0          4s
```

You can see that under the READY column, you have "0/3" - three containers.
If you run it after a minute or so, they'll be ready

## Sidecar example

A usecase in which multi-container pods can be useful is when we have an application that is hard-coded
to write logs to a file on disk. In this case, it's gonna be hard for the developer to view those logs since they're
written to the filesystem of the container.

In this case, what we want to do is to have another "sidecar" container that will read these logs and output them to the console
so we can view them using `kubectl logs`

This is demonstrated in the `sidecar-pod.yaml` example
Go ahead and create that pod

```
$ kubectl apply -f sidecar-pod.yaml
```

Now if we want to access the log:

```
$ kubectl logs sidecar-pod -c sidecar
logs data
```

