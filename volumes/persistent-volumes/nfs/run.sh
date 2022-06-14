#!/bin/bash

docker run                                            \
  -v /mnt/nfs_share:/tmp  \
  -e NFS_EXPORT_0='/tmp *(rw,no_subtree_check)' \
  --privileged                                 \
  -p 2049:2049  \
  -p 111:111 \
  -p 32765:32765 \
  -p 32767:32767 \
  erichough/nfs-server
