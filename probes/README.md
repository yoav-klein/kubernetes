i
# Probes
---

Probes help you detect the health of your containers so k8s could automatically restart them 
or do different actions when they are unhealthy.

Probes come in 3 types:

## Liveness probes
Liveness probes run on an on-going basis. Each interval of time, they do a certain check
to see that the container is healthy.
Liveness probes come in several types.

```
$ kubectl apply -f liveness-probe.yaml
```

## Startup Probe
The startup probe will run for a specified amount of times, and once it succeeds it will no longer run again, but rather 
pass control to the other probes. Both the other probes will not start until this probe will pass successfully.
It will try running for `failureThreshold` times, with `periodSeconds` seconds in between. Once it succeeds once,
it will stop running.

```
$ kubectl apply -f startup-probe.yaml
```

## Readiness Probe
Readiness probes indicate whether or not your application is ready to receive traffic.

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

## Handlers
Probes are executed using _Handlers_. There are 3 types of handlers:

### Exec type
The `liveness-probe.yaml` demonstrates the use of this type. It executes a command 
every 5 seconds (starting 5 seconds after container startup), and if the command fails
at some point, the container is considered unhealthy.

### httpGet type
This type sends an HTTP request to the specified port every x seconds, and verifies that it gets a successful
response code

```
$ kubectl apply -f liveness-http-probe.yaml
```

### TCPSocketType
This is also a type, see the docs.

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

## Multi-container
In this demo, what I wanted to check is what happens when you have 2 containers in a Pod, with a probe configured (at least for one of them): What happens
on failure? Do all the containers in the Pod are restarted?

Turns out that no (Which makes sense) - only the failing container is restarted

```
$ kubectl apply -f multi-container-pod.yaml
```

After a while, the `failing` container fails. You can know that the `succeeding` pod did not restart, since the `/var/log/success.txt` file is preserved:
```
$ kubectl exec multi-container-pod -c succeeding -- cat /var/log/success.txt
Success!!
Success!!
```

So you see that this container hasn't been restarted.

You can also see it this way: Run:
```
$ kubectl get pod multi-container-pod 
```

Under `status.containerStatues` you can see both the containers. You can see that each has its own count of `restarts`
