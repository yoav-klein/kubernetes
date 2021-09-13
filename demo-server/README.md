
# Demo Server
---

This directory contains a demo server in node.js, and a Dockerfile to create a dockerized application of it.
You can use this as a demo application for playing with Kubernetes: Build several versions of it to experience with
rollouts etc.

## Build
Specify the version in the `server.js` file, and build the image
```
$ docker build -t server:<VERSION> .
```

You can now push it to Docker Hub or some other registry (most convenient to Docker Hub).
```
$ docker tag server:<VERSION> yoavklein3/server:<VERSION>
$ docker push yoavklein3/server:<VERSION>
```


## Run
```
$ docker run -t -p 8080:3000 server:<VERSION>
```
