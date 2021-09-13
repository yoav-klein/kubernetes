
# Deployments
---

Deployments enable you to ensure that a desired state will always be satisfied.
A Deployment creates a set of replica pods. You configure how many of them should be always up and running,
and the containers they should run (along with other configurations), and the Deployment controller will take care
of maintaining this desired state.

### Prerequisites for this Demo
We need to have a Repository in Docker Hub named `server` with 3 tags: `1.0`, `2.0` and `3.0`
These Docker images contain a node.js server which just prints "This is server version <X>"

Actually I already created these, and there's the application and Dockerfile in the `demo-server` folder.

## Demo
In this demo we have a `deployment.yaml`file which defines a Deployment with 3 replicas of a pod,
which runs 1 container of the `yoavklein3/server:<x>` image.

```
$ kubectl apply -f deployment.yaml
```

Now, run
```
$ kubectl get deployments
```

You can see how many pods are running out of how many should be running. You also see the UP-TO-DATE
field which specifies how many pods are up to date with the configuration in the YAML file. If you change
e.g. the image, this will be gradually increasing (starting from zero I suppose).

You can test the application by creating the `test-pod` which runs `curl`:

First, create the Pod:
```
$ kubectl apply -f test-pod.yaml
```

Now get the IP of one of the Pods:
```
$ kubectl get pods -o wide
NAME                             READY   STATUS    RESTARTS   AGE     IP                NODE                           NOMINATED NODE   READINESS GATES
my-deployment-6c94fdf8bd-9xzd5   1/1     Running   0          8m57s   192.168.235.129   worker1                        <none>           <none>
my-deployment-6c94fdf8bd-ks2hk   1/1     Running   0          8m57s   192.168.235.132   worker1                        <none>           <none>
my-deployment-6c94fdf8bd-qj7zm   1/1     Running   0          8m57s   192.168.235.130   worker1                        <none>           <none>
```

Now use the test-pod to curl one of the Pods:
```
$ kubectl exec test-pod -- curl 192.168.235.129:3000
Hello world ! Version 1
```

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

## Rolling updates
When you change your Deplyoment's Pods, such as changing the image of the pod, k8s will _rollout_ your new pods,
meaning it will first spawn the new pods, and only then destroy the old ones.

You can roll an update in a few ways:

1. Just update the Deployment's YAML and apply it.
2. Using the `kubectl set image` command

Let's use the second approach in order to upgrade our application to version 2:

```
$ kubectl set image deployment/my-deployment server=yoavklein3/server:2.0 --record
```

Note that the `--record` flag is used so that the history will tell us the command that was used for this rollout.

You can view the status of the rollout:
```
$ kubectl rollout status deployment/my-deployment
Waiting for deployment "my-deployment" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "my-deployment" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "my-deployment" rollout to finish: 2 old replicas are pending termination...
Waiting for deployment "my-deployment" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "my-deployment" rollout to finish: 1 old replicas are pending termination...
```

You can repeat the process of curling to one of the Pods to check that the new version is now deployed.

You can view the rollouts history:
```
$ kubectl rollout history deployment/my-deployment
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment/my-deployment server=yoavklein3/server:2.0 --record=true
```


### Rollback
If you aren't happy with the new version of your application and want to rollback to an older version, you can do it:

```
$ kubectl rollout undo deployment/my-deployment
```

This will undo the last rollout.
If you now look at the history:

```
$ kubectl rollout history deployment/my-deployment
deployment.apps/my-deployment 
REVISION  CHANGE-CAUSE
2         kubectl set image deployment/my-deployment server=yoavklein3/server:2.0 --record=true
3         <none>
```
You see that this rollback is another revision actually.

Now let's make our history richer by deploying version 3:
```
$ kubectl set image deployment/my-deployment server=yoavklein3/server:3.0
```

Now your history should look like this:
```
$ kubectl rollout history deployment/my-deployment
REVISION  CHANGE-CAUSE
4         kubectl set image deployment/my-deployment server=yoavklein3/server:2.0 --record=true
5         <none>
6         kubectl set image deployment/my-deployment server=yoavklein3/server:3.0 --record=true
```

You can also rollback to a specific version. Say you want to rollback to version 2.0:

```
$ kubectl rollout undo deployment/my-deployment --to-revision=4
```
