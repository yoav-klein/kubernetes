#!/bin/bash

# creating a key
openssl genrsa -out yoav.key

# NOTE: the CN must correspond to the name in the RoleBinding
openssl req -new -key yoav.key -out yoav.csr \
  -subj "/CN=yoav/O=system:masters"

# sign the csr with the cluster's CA
sudo openssl x509 -req -in yoav.csr -CA /etc/kubernetes/pki/ca.crt \
  -CAkey /etc/kubernetes/pki/ca.key \
  -CAcreateserial \
  -out yoav.crt -days 365

