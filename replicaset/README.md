
 ReplicaSet
---

This is a demo of using ReplicaSets.
It basically demostrates the way ReplicaSets acquire standalone Pods using `matchLabels`

So we have a ReplicaSet `my-replicaset` which has a Pod template which runs the `server:1.0` image container.

## Create the ReplicaSet
Create the ReplicaSet with

````
$ kubectl apply -f replica-set.yaml
```

See the Pods that were created:
```
$ kubectl get pods
NAME                  READY   STATUS    RESTARTS   AGE
my-replicaset-4jjpz   1/1     Running   0          118s
my-replicaset-nxf2r   1/1     Running   0          118s
my-replicaset-rn6hs   1/1     Running   0          118s
```

You see that Pods were created with the name of the ReplicaSet with some identifier.
You can see that these Pods belong to the ReplicaSet:

```
$ kubectl get pod -o yaml my-replicaset-4jjpz
...
 metadata: 
...
 ownerReferences:
  - apiVersion: apps/v1
    blockOwnerDeletion: true
    controller: true
    kind: ReplicaSet
    name: my-replicaset
    uid: e07a41f8-0870-4aae-85c7-9ba463209561
  resourceVersion: "579429"
  uid: 74e51bf4-1fcb-4af0-9fa8-95aaf90168c5
...
```

You can see that the Pod belongs to the ReplicaSet in the `.metadata.ownerReferences` field

## Create a ReplicaSet when a Pod exists
Delete the ReplicaSet
```
$ kubectl delete rs my-replicaset
```

Now, run the standalone Pod `single-pod.yaml` which has the label `app: my-app` (same as the Pod template of the RepliaSet)
```
$ kubectl apply -f single-pod.yaml
```
Now create the replica-set:

```
$ kubectl apply -f replica-set.yaml
```

Get the Pods:
```
$ kubectl get pods
NAME                  READY   STATUS    RESTARTS   AGE
my-replicaset-wfs28   1/1     Running   0          3s
my-replicaset-zdwtm   1/1     Running   0          3s
server-v2             1/1     Running   0          50s
```

You can see that the ReplicaSet _acquired_ the already existing Pod `server-v2`. This is because the `app: my-app` is set to this Pod.

```
$ kubectl get pod -o yaml server-v2
apiVersion: v1
kind: Pod
metadata:
  annotations:
    cni.projectcalico.org/containerID: 799ff140fd34b406da8cbb4638557dda74cdfe38f3df630c9b088bb51b93f7cd
    cni.projectcalico.org/podIP: 192.168.3.113/32
    cni.projectcalico.org/podIPs: 192.168.3.113/32
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"app":"my-app"},"name":"server-v2","namespace":"default"},"spec":{"containers":[{"image":"yoavklein3/server:2.0","name":"server-version-2"}]}}
  creationTimestamp: "2021-09-14T08:25:41Z"
  labels:
    app: my-app
  name: server-v2
  namespace: default
  ownerReferences:
  - apiVersion: apps/v1
    blockOwnerDeletion: true
    controller: true
    kind: ReplicaSet
    name: my-replicaset
    uid: 85eecad3-669f-41ba-ad12-261db981a686
  resourceVersion: "580263"
  uid: c1802ecf-8685-4139-840c-6f25954616b6
```

You can see that we now have the `.metadata.ownerReferences` field. The `my-replicaset` is the owner of this Pod.
