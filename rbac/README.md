
# RBAC
---
This folder contains a demonstration of Role Based Access Control.

There is a demonstration for dealing with a human user, as well as a ServiceAccount

We are creating a Role `pod-reader` which defines permissions to get, list and watch pods.
Then we create a RoleBinding that binds both a User and a ServiceAccount to that Role.
We'll then demonstrate how to get pods using that User and ServiceAccount

### Setup:
- Use the `create_user_certificate.sh` script to generate the PKI infrastructure for the user.
That script will generate a private key, a Certificate Signing Request, and will sign it with the
CA of the cluster. This must be done on the master machine, with priviliges to access the CA private key.
- Create a namespace in the cluster named `my-app` 
- Create a Role in the namespace, using the `role.yaml` file
- Create a RoleBinding in the namespace, using the `role-binding.yaml` file

### Working with a User
What we are simulating here is a situation in which we have some user
that we wish to grant him certain permissions in a certain namespace in the cluster.

So we create a Role, specifying the _rules_, which are the permissions given. In this case, to get, list and watch pods in the `my-app` namespace.
And we create a RoleBinding, associating a user with that Role.

Notice that a user is defined only by his name. Anyone that will provide a certificate with 
this name in the `CN` field of the certificate, signed by the cluster's CA will be
considered to be this user. 

The RoleBinding binds the user named "yoav" to that role.

NOTE: the CN of the certificate, the name of the user in the `.kube/config` file and the name of the user in the RoleBinding
must all match.

#### Steps:
- Make sure you have a machine/user that will simulate that user.
- Copy the PKI files (`.crt`, `.key`) to that machine. The certificate must have the name "yoav" as the CN.
- Create a .kube/config file pointing tho the cluster's URL, and defining a user named "yoav" pointing to the 
`.key` and `.crt` files. There's a `example-kubeconfig` that you can use.
 
#### Running the demo
Run
```
$ kubectl get pods -n my-app
```

You should see it working.

### Working with ServiceAccount
A ServiceAccount is used when you want a process in a container in a pod to access the API server of k8s.
The process is as follows:
- You create a ServiceAccount in the namespace.
- Bind the ServiceAccount to a Role using a RoleBinding.
- Run a pod with the `spec.serviceAccountName` field, specifying the ServiceAccount you created.

#### Steps
1. Create a ServiceAccount in the namespace:
```
$ kubectl apply -f service-account.yaml
```

2. Bind the ServiceAccount to a Role using the `role-binding.yaml
```
$ kubectl apply -f role-binding.yaml
```

#### Running the Demo
To see it working, create a Pod with `curl` in it. Use the `service-account-pod.yaml`.
Connect to the container using:
```
$ kubectl exec -it <pod-name> /bin/sh
```

Now go to the directory where the ServiceAccount data is placed:
```
$ cd /run/secrets/kubernetes.io/serviceaccount 
$ ls
namespace token ca.crt
```

And run:
```
$ CA=$PWD/ca.crt
$ TOKEN=$(cat token)
$ curl --cacert $CA --header "Authorization: Bearer $TOKEN" https://kubernetes.default.svc:443/api/v1/namespaces/my-app/pods
```

You should see a list of pods
