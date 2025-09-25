# Horizontal Pod Autoscaling
---

In this project we demonstrate the use of `HorizontalPodAutoscaler`

Quick reminder - Horizontal Pod Autoscaling is the process of starting and destroying pods based on some metrics.
This is in constrast to Vertical Pod Autoscaling where we add resources to pods in response to higher demand.

Here we demonstrate autoscaling based on memory usage.

## What we have here

We have the `java-stress` application from our `docker-images` repository running as a Deployment.
Initially, each container will consume 100MB of memory. We'll then exec into the first pod and raise the memory consumption.

We have a `HorizontalPodAutoscaler` which specifies a desired utilization of `50%`. Considering that we define a memory request of 1Gi 
on our containers, this means that when there'll be an average of 500MB consumed across all the pods, scaling out will occur.

## Usage

First, deploy the `deployment.yaml` and the `hpa.yaml`.

At first, you'll have only one pod running.
Now, exec to the pod and increase the memory usage:

```
$ kubectl exec -it <pod> -- bash
$ curl localhost:8090/update?size=700
```

This will increase the memory consumption to 700MB, which means that a scale out will occur.

You can then scale down and see what happens.

## Useful commands

Get memory stats of JVM:
```
$ jhsdb jmap --heap --pid 8
```

Initiate a Garbage Collection:
```
$ jcmd 8 GC.run
```
