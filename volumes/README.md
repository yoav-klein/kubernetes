# Volumes
Volumes allow you to:
* Persist data outside of the lifecycle of a Pod
* Share data across containers in a Pod

There are several types of volumes in Kubernetes, and they divide to 2
categories: Persistent and ephemeral.

Ephemeral volumes, such as `emptyDir` have the same lifecycle as the pod they're running with.
Persistent volumes on the other hand, persist outside the lifecycle of a pod.

This folder contains examples of different kinds of Volumes
