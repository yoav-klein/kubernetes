i
# Probes
---

Probes help you detect the health of your containers so k8s could automatically restart them 
or do different actions when they are unhealthy.

## Liveness probes
Liveness probes run on an on-going basis. Each interval of time, they do a certain check
to see that the container is healthy.
Liveness probes come in several types.

### Exec type
The `liveness-probe.yaml` demonstrates the use of this type. It executes a command 
every 5 seconds (starting 5 seconds after container startup), and if the command fails
at some point, the container is considered unhealthy.

```
$ kubectl apply -f liveness-probe.yaml
```

### httpGet type
This type sends an HTTP request to the specified port every x seconds, and verifies that it gets a successful
response code

```
$ kubectl apply -f liveness-http-probe.yaml
```

## Startup Probe
These also have the types "exec" and "httpGet", but the startupProbe just makes sure that the program started up.
So it will try running for `failureThreshold` times, with `periodSeconds` seconds in between. Once it succeeds once,
it will stop running, and a liveness probe (if defined) will take over

```
$ kubectl apply -f startup-probe.yaml
```

## Readiness Probe

```
$ kubectl apply -f readiness-probe.yaml
```

Run 
```
$ kubectl get pods
```

You can see this pod is in the Running state, but 0/1 containers are ready,
So traffice will not be routed to this pod.
that's until the readiness probe is succeeded, in which it will turn to 1/1

## Failing container
There's an example of a container that fails. That failure is detected by the probe. Create the Pod:

```
$ kubectl apply -f failing-container.yaml
```

After a minute or so, you can see that the container is being restarted (run `kubectl get pods`)

You can see what happens in the Pod by running:
```
$ kubectl describe pod failing-container
...
  Normal   Pulled     4m12s                  kubelet            Successfully pulled image "busybox" in 1.192642965s
  Warning  Unhealthy  3m28s (x9 over 6m8s)   kubelet            Liveness probe failed: cat: can't open '/tmp/healthy': No such file or directory
```

You can see that the Pod is "Unhealthy"
