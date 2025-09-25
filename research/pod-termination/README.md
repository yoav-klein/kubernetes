# Pod Termination
---

Here we investigate the behavior of pod termination.

We have in the `research` pod a `preStop` hook that sends a request to the `echo` pod.
Also, there's a `terminationGracePeriodSeconds` in the `research` pod.

Apply both pods, and then kill the `research` pod. You'll see that it will survive for 50 seconds (which is the `terminationGracePeriodSeconds`). 
