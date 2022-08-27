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




