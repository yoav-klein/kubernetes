# Liveness Probes
---

Liveness probes are used by the kubelet to determine whether the container is alive and healthy.
Liveness probes run on a regular basis, each `periodSeconds` seconds.

There are several types of probes - i.e. - several methods for the kubelet to determine if the container
is healthy.

## exec
In this method, the kubelet runs a command in the container, and if the command returns a status code of 0
it is considered healthy. Otherwise - it is restarted

Apply the `liveness-exec.yaml` file, which creates a pod with one container with a `exec` liveness probe.
After a minute, run:
```
$ kubectl describe pod liveness-exec
```

## HTTP
Another kind of liveness probe is HTTP. The kubelet issues a HTTP GET request to the application
running in the container, to the specified port, and if it gets a success status code, the container
is considered healthy.

In the `liveness-http.yaml` file, we create a pod with a container running a server application which, after 10 seconds,
starts returning 500 status code, so the kubelet will restart it:

```
$ kubectl apply -f liveness-http.yaml
```

After 15 seconds or so, run `kubectl describe` on the pod to see that the liveness probe fails.
