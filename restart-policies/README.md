# Restart Policies
---

Restart policies allow you to define when your pod should be restarted.
There are 3 policies: Always, OnFailure and Never.
Their names are pretty self explanatory.

## Always
Run the `always-pod.yaml` pod

```
$ kubectl apply -f alway-pod.yaml
```

Now watch the pod
```
$ watch kubectl get pods
```

And you'll see that it always restarts after it is completed.

## OnFailure

Run the `onfailure-pod.yaml` pod

When you run 
```
$ kubectl get pods

NAME           READY   STATUS      RESTARTS   AGE
onfailure-pod   0/1     Completed   0          63s
```

You see it's in a completed status, and not restarted
