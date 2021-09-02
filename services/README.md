
# Services
---

## Intro
Services let you expose a set of replica Pods as an application, without needing to know
about the actual Pods. It's an abstraction layer above the Pods. So the client will request
the Service, and this request will be routed to one of the Pods in a load-balanced fashion

## Demo
First, we'll create a Deployment, which runs 3 Pods of nginx.
```
$ kubectl apply -f deployment-svc-example.yaml
```

### ClusterIP
Now, we will create a ClusterIP Service that exposes these Deployment's Pods within the cluster.
```
$ kubectl apply -f svc-clusterip.yaml
```

NOTES:
* The spec of the Service contains a `selector` field. This determines which Pods will belong to this Service.
* ports[i].port - this is the port that the Service exposes. Clients communicating with the Service will use port 80
* ports[i].targetPort - this is the port that the Service is routing traffic to. So this is the port that the applications in the Pods should be listening on.
* It's completely arbitrary that in this example we use 80 for both, they could be different of course.

Now let's see the Endpoints for our Service:
```
$ kubectl get endpoints svc-clusterip
NAME            ENDPOINTS                                                AGE
svc-clusterip   192.168.235.186:80,192.168.235.187:80,192.168.3.104:80   60s
```

Now let's test our Service. It's of type ClusterIP, so it's only accessible from within the cluster. 
Let's create a Pod that we can use to test the Service:
```
$ kubectl apply -f test-svc-pod.yaml
```

Now let's exec a `curl` command from within our Pod to the Service:
```
$ kubectl exec svc-test-pod -- curl svc-clusterip:80
```

Note that we can just refer to the Service using the Service name

### NodePort
Now let's create a NodePort Service, which routes traffic to the same Pods we created before.

```
$ kubectl apply -f svc-nodeport.yaml
```

Notes:
* The `ports[i].nodePort` setting - this is the port on which each of the nodes listens on, and upon receiving a request, will route
traffic to this Service.
* The `ports[i].port` setting functions the same as in ClusterIP - it's used as the port that clients from within (!) the cluster use to access
this Service.

Now browse from your browser to: `<one_of_the_nodes_IP>:30800` 
You should see the Nginx page.
