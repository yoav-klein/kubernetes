
# RBAC
---
This is a demonstration of Role Based Access Control

What we are simulating here is a situation in which we have some user
that we wish to grant him certain permissions in a certain namespace in the cluster.

So we create a Role, specifying the _rules_, which are the permissions given.
And we create a RoleBinding, associating a user with that Role.
The user is defined only by his name. Anyone that will provide a certificate with 
this name in the `CN` field of the certificate, signed by the cluster's CA will be
considered to be this user. 


The Role defines permissions to get, watch and list pods in the
`my-app` namespace.

The RoleBinding binds the user named "yoav" to that role.

### Prerequisites:
- a namespace named `my-app` in your cluster, preferably with at least a pod in it.
- a user named "yoav", which means:
  - a certificate signed with the cluster's CA, with "yoav" as the CN
  - a .kube/config file pointing to the cluster's URL, and defining a user 
    named "yoav" pointing to the yoav.key and yoav.crt files
 
### Running the demo
- You can use the `create_user_certificate.sh` script to handle the PKI part. 
That script will generate a private key, a Certificate Signing Request, and will sign it with the
CA of the cluster. This must be done on the master machine, with priviliges to access the CA private key.
- Create some user - which we are simulating - or alternatively use another machine. Copy the private key and certificate to that user's home.
- Create a `.kube/config` file pointing to the URL of the cluster's API server, and defining a user using the 
previously created certificate and private key. There's an example one here.

### Test
Run
```
$ kubectl get pods -n my-app
```

You should see it working.
