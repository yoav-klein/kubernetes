
# Startup Probes
---

Startup probes are meant to use with applications that take some time to start up.
Startup probes run before liveness and readiness probes start running, and only
when succeeds, it gives control to liveness and readiness probes.

In this example, we have a container which will create a file `/hello.txt` 30 seconds after it starts.
We define a startup probe which will try to `cat` this file. This will of course fail
fo the initial 30 seconds, so if the `failureThreshold * periodSeconds` is greater than 30 seconds, 
the startup probe will be considered failed, and it will restart the container.


This is the output of `kubectl describe pod` when the startup probe fails:
```
 Type     Reason     Age                  From               Message
  ----     ------     ----                 ----               -------
  Normal   Scheduled  2m54s                default-scheduler  Successfully assigned test/startup-pod to 10.195.6.92
  Normal   Pulled     2m50s                kubelet            Successfully pulled image "busybox:latest" in 2.600295214s
  Normal   Pulling    70s (x2 over 2m53s)  kubelet            Pulling image "busybox:latest"
  Normal   Created    68s (x2 over 2m50s)  kubelet            Created container startup
  Normal   Pulled     68s                  kubelet            Successfully pulled image "busybox:latest" in 2.558788279s
  Normal   Started    67s (x2 over 2m50s)  kubelet            Started container startup
  Warning  Unhealthy  35s (x8 over 2m45s)  kubelet            Startup probe failed: cat: can't open '/hello.txt': No such file or directory
  Normal   Killing    1s (x2 over 100s)    kubelet            Container startup failed startup probe, will be restarted
```

Now let's change the values of `failureThreshold` to 10 and `periodSeconds` to 5, and change the sleep to 40,
 so that it will succeed after around 7/8 trials.
In this case, you'll see the output as such:

```
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  53s                default-scheduler  Successfully assigned test/startup-pod to 10.195.6.92
  Normal   Pulling    53s                kubelet            Pulling image "busybox:latest"
  Normal   Pulled     51s                kubelet            Successfully pulled image "busybox:latest" in 2.581900073s
  Normal   Created    51s                kubelet            Created container startup
  Normal   Started    51s                kubelet            Started container startup
  Warning  Unhealthy  16s (x7 over 46s)  kubelet            Startup probe failed: cat: can't open '/hello.txt': No such file or directory
```

So it seems that there isn't an event telling you explicitly that the startup probe succeeded, but if you don't see the `will be restarted` thing,
apparently it succeeded.

