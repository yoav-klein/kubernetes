# Config Maps
---

Config Maps allow you to define key-value data store as a Kubernetes object. Your containers can then refer to this information in differente ways.

## The Config Map object
In this example, we have a ConfigMap called `dog-config` that is defined to be created in the `configmap` namespace.

## The pod object
We also have a pod spec, created also in the same namespace.

The pod defines only one container of image "ubuntu". The container is configured with `env` section (environment variables), which are taken from the config map defined before.
This is one way of consuming Config Maps data.

Another way is using _volumes_. In the pod spec, we define a volume that can be mounted to the container. This volume is of type `configmap`, which means that you specify a
YAML list, in which each item defines the key in the Config Map and a path to put the value in. A file will be created for each key-value, and the container can mount this volume 
wherever he likes.


## Run
1. Make sure you have the `configmap` namespace.
2. Create the Config Map object:
```
$ kubectl apply -f config-map.yaml
```

3.Create the pod:
```
$ kubectl apply -f pod.yaml
```

4. Now, exec into the pod:
```
$ kubectl exec -n configmap dogs-application /bin/bash
```

5. Now you can see the config map data through the environment variables
```
$ env
DOG_TYPE=labrador
...
DOG_COLOR=yellow
```

Or you can see it in the file system:
```
/config# ls
color  size  type
```
