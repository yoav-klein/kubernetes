
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
