
# Deployments
---

Deployments enable you to ensure that a desired state will always be satisfied.
A Deployment creates a set of replica pods. You configure how many of them should be always up and running,
and the containers they should run (along with other configurations), and the Deployment controller will take care
of maintaining this desired state.

In this demo we have a `deployment.yaml`file which defines a Deployment with 3 replicas of a pod,
which runs 1 nginx container.

```
$ kubectl apply -f deployment.yaml
```

Now, run
```
$ kubectl get deployments
```

You can see how many pods are runnin out of how many should be running. You also see the UP-TO-DATE
field which specifies how many pods are up to date with the configuration in the YAML file. If you change
e.g. the image, this will be gradually increasing (starting from zero I suppose).


## Trying to delete a Deployment pod
To see the deployment-controller in action, let's delete a pod:

```
$ kubectl get pods
```
take note of one of the `my-deployment...` pods, and delete it:

```
$ kubectl delete pods my-deployment...
```

Now list the pods again, and see that there's another one instead of it.

```
$ kubectl get pods
```


## Scaling up or down
Kubernetes Deployments allows you to _Horizontally scale_ your application by adding or deleting pods to your Deployment.
You can do so by simply editing the YAML of the Deployment and change the `replicas` setting and then run `kubectl apply -f deployment.yaml`
or you can use the `kubectl scale` command.
