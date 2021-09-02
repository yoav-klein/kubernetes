
# NetworkPolicies
---

NetworkPolicies allow you to restrict network traffic to and from Pods.

### Basic setup
First create a namespace to keep things clean:

```
$ kubectl create ns np-test
```

Now attach a label to that namespace:

```
$ kubectl label namespace np-test team=np-test
namespace/np-test labeled
```
We'll use that in the future to create a _namespaceSelector_

Now we'll create a Pod in that namespace, with the `app: nginx` label
```
$ kubectl apply -f np-nginx.yaml
```

We have a client Pod running busybox, witjh a label `app: client`
```
$ kubectl apply -f np-busybox.yaml
```

Now, try to communicate the nginx pod form the client Pod:
```
$ kubectl get pods -o wide -n np-test
< note the nginx IP > into NGINX_IP

$ kubectl  exec -n np-test np-busybox -- curl $NGINX_IP
```
You should see "Welcome to Nginx" - everything works fine.
Right now, there aren't any NetworkPolicies, so there's no problem.

### Create a NetworkPolicy
We have a `my-networkpolicy-restricted.yaml` that defines a NetworkPolicy object.
It selects pods with the `app: nginx` label.
First, we define both Ingress and Egress, but we aren't allowing anything.

Apply this NetworkPolicy
```
$ kubectl apply -f my-networkpolicy-restricted.yaml
```

Now try curling again:
```
$ kubectl exec -n np-test np-busybox -- curl $NGINX_IP
```

Now you see that the `curl` command is just hanging.

Now let's edit our NetworkPolicy to allow ingress from a `namespaceSelector`. 
We simply add a `ingress` rule to the spec of our NetworkPolicy. This is done in `my-networkpolicy.yaml` 

```
$ kubectl apply -f my-networkpolicy.yaml
```
