# Finishing container
---

Now let's see what happens when the sidecar container exits successfully after 30 seconds.

You'll see that after 30 seconds, running `kubectl get po -oyaml` will give you:
```
    - containerID: containerd://200fe829a99fa032ccb1cf4465591fac7642002d015700fe7af3853a1136b413
      image: docker.io/library/busybox:latest
      imageID: docker.io/library/busybox@sha256:2f590fc602ce325cbff2ccfc39499014d039546dc400ef8bbf5c6ffb860632e7
      lastState:
        terminated:
          containerID: containerd://22686b6b4897ee7c11a842c7878b2a77eaeed74961f531c48ce0294deb08b8ce
          exitCode: 0
          finishedAt: "2025-10-16T11:23:43Z"
          reason: Completed
          startedAt: "2025-10-16T11:23:13Z"
      name: sidecar-container
      ready: true
      resources: {}
      restartCount: 1
      started: true
      state:
        running:
          startedAt: "2025-10-16T11:23:44Z"

```

The container was restarted, since the default restartPolicy is Always. 
So now it's running, but the lastState was terminated, with exitCode: 0, reason: Completed.

After a while, it'll get in the backoff mechanism, where the container will be in the `waiting` state due to the backoff delay mechanism.
