
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

## Service DNS Discovery
When you create a Service in K8s, the Service has a domain name. The format a domain name is:
```
<service-name>.<namespace-name>.svc.<cluster-domain>
```

The default cluster-domain is `cluster.local`

In our example, the `cluster-ip` Service has a domain name. Let's see it:
```
$ kubectl get svc svc-clusterip
# note the IP address of the service
$ kubectl exec svc-test-pod -- nslookup <IP>
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      10.98.32.167
Address 1: 10.98.32.167 svc-clusterip.default.svc.cluster.local
```

You can see that the domain name is `svc-clusterip.default.svc.cluster.local`
You can communicate with the Service using this name:
```
$ kubectl exec svc-test-pod -- curl svc-clusterip.default.svc.cluster.local
```

Since our `svc-test-pod` is also running in the default namespace, as the `svc-clusterip` Service, we can simply refer to the Service
using its name alone:

```
$ kubectl exec svc-test-pod -- curl svc-clusterip
```

Note that from Pods within a different namespace, you have to use the fully-qualified name.

## Ingress
We have a `my-ingress.yaml` file that contains an Ingress definition. That Ingress is routing the path `/somepath` 
to our `svc-clusterip` Service.
