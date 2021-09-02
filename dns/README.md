
# Kubernetes DNS
---

## Intro
We have a DNS server in our cluster. Each Pod gets a domain name of a certain format:
```
<dash-separated-ip>.<namespace>.pod.cluster.local
```

The DNS is running as Pod(s) in the cluster. We're using Kubeadm which uses _coredns_.
```
$ kubectl get pods -n  kube-system
...
coredns-558bd4d5db-25gxc                   1/1     Running   17         29d
coredns-558bd4d5db-sx9hx                   1/1     Running   17         29d
```

These pods are exposed as a service:
```
$ kubectl get service -n kube-system
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   29d
```

## Hands-on Demo
In the `dnstest-pods.yaml` we have 2 Pods, go ahead and create them:
```
$ kubectl apply -f dnstest-pods.yaml
```

Now, let's use the domain name of the `nginx` Pod to find its IP address in the `busybox` pod:
First, get the IP of the nginx Pod:
```
$ kubectl get pods nginx-test -o wide
```

Supposing the IP of this Pod is `192.168.3.97`, the domain name is `192-168-3-97.default.pod.cluster.local`

```
$ kubectl exec busybox-dnstest -- nslookup 192-168-3-97.default.pod.cluster.local
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      192-168-3-97.default.pod.cluster.local
Address 1: 192.168.3.97
```

We get a response.

