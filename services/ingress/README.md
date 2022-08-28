# Ingress
---

## Intro

Ingress is basically a gateway for HTTP/HTTPS traffic to your services. Ingress
provides load-balancing, name-based virtual hosting and SSL termination.

In this example, we create the following objects:
1. A deployment for a Web application + a service that exposes this deployment
2. A deployment for an API +  a service that exposes this deployment

Then, we create an Ingress object which defines rules for routing traffic
to these services based on the path in the URI.

## Usage

### 1. Deploy an Ingress Controller
First, we need an Ingress Controller in the cluster. 
We'll use the Nginx Ingress Controller.

Run this:
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/cloud/deploy.yaml
```


### 2. Create the deployments and services
First, create the `ingress-demo` namespace
```
$ kubectl create ns ingress-demo
```

Create the deployment and service resources for the "joke API" and "joke Web" applications:
```
$ kubectl apply -f  resources.yaml
```

### 3. Create the Ingress object
```
$ kubectl apply -f ingress.yaml
```

### 4. Test
This step really depends on your configuration.
Basically what we need is to reach the Ingress Controller service using the `joke.com` domain name.
You can do this in all sort of ways, here's one of them:

On the control plane node:
a. Edit the `/etc/hosts` file so that `joke.com` will translate to localhost
b. Port-forward the `ingress-nginx-controller` service (port 80) to some port on localhost (say 8080)
```
$ kubectl port-forward -n ingress-nginx ingress-nginx-controller 8080:80
```
c. Now run `curl joke.com:8080/web` or `curl joke.com:8080/api`

And there you go!


## Cleanup
1. Delete the `joke.com` entry from the `/etc/hosts` file
2. `kubectl delete ns ingress-demo`
3. Optionally - `kubectl delete ingress-nginx` (to delete the ingress controller)
