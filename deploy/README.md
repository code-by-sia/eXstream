# Deploying eXstream on Kubernetes

This folder contains the Kubernetes objects for the whole stack, grouped by kind:

| File                | Objects                                                           |
|---------------------|-------------------------------------------------------------------|
| `namespace.yaml`    | `exstream` Namespace                                              |
| `secrets.yaml`      | `exstream-jwt` Secret (shared `JWT_SECRET`)                       |
| `configmaps.yaml`   | `web-nginx` ConfigMap (SPA-only nginx config)                     |
| `volumes.yaml`      | PersistentVolumeClaims: `auth-data`, `playlist-data`, `file-data` |
| `deployments.yaml`  | Deployments: `auth`, `playlist`, `file`, `forward-auth`, `web`    |
| `services.yaml`     | ClusterIP Services for each Deployment                            |
| `hpa.yaml`          | HorizontalPodAutoscalers for `web` and `forward-auth`             |
| `ingressroute.yaml` | Traefik `Middleware` (ForwardAuth) + `IngressRoute`               |

## Prerequisites

- A Kubernetes cluster (k3s, kind, minikube, or managed) and `kubectl` pointed at it.
- **Traefik v3 with the `kubernetesCRD` provider** — the routing uses Traefik's
  `IngressRoute`/`Middleware` CRDs. k3s ships Traefik by default; elsewhere install it
  with Helm: `helm install traefik traefik/traefik`.
- The IngressRoute binds to Traefik's `web` entrypoint (port 80/8000 by default).
- **metrics-server** for the HPAs (`kubectl top nodes` should work).
- A default StorageClass for the PersistentVolumeClaims.
- A container registry the cluster can pull from.

## 1. Build and push the images

The manifests reference `ghcr.io/code-by-sia/exstream-<component>:latest`.
Replace the prefix with your own registry if it differs (one `sed` across
`deployments.yaml`), then build from the repository root:

```sh
REGISTRY=ghcr.io/code-by-sia

docker build -f auth/Dockerfile     -t $REGISTRY/exstream-auth:latest .
docker build -f playlist/Dockerfile -t $REGISTRY/exstream-playlist:latest .
docker build -f file/Dockerfile     -t $REGISTRY/exstream-file:latest .
docker build -f api/Dockerfile      -t $REGISTRY/exstream-forward-auth:latest api
docker build                        -t $REGISTRY/exstream-web:latest web

docker push $REGISTRY/exstream-auth:latest
docker push $REGISTRY/exstream-playlist:latest
docker push $REGISTRY/exstream-file:latest
docker push $REGISTRY/exstream-forward-auth:latest
docker push $REGISTRY/exstream-web:latest
```

The `web` build uses the Dockerfile's default (production) target: Vite build
served by nginx. The Xi service images install the Xi toolchain with `brew
install code-by-sia/xi/xi` (the tap tracks the latest release); no other
build-time dependency fetch is needed.

For local clusters you can skip the registry: `kind load docker-image …` or
`k3s ctr images import …` after building.

## 2. Create the namespace and the JWT secret

```sh
kubectl apply -f deploy/namespace.yaml

kubectl -n exstream create secret generic exstream-jwt \
  --from-literal=JWT_SECRET="$(openssl rand -hex 32)"
```

`secrets.yaml` carries a `change-me` placeholder so the manifests are complete;
prefer creating the secret out of band as above (skip applying `secrets.yaml`),
or edit the value before applying. `auth` (token issuer) and `forward-auth`
(token verifier) must see the same value.

## 3. Apply everything else

```sh
kubectl apply -f deploy/configmaps.yaml
kubectl apply -f deploy/volumes.yaml
kubectl apply -f deploy/deployments.yaml
kubectl apply -f deploy/services.yaml
kubectl apply -f deploy/hpa.yaml
kubectl apply -f deploy/ingressroute.yaml
```

(Or simply `kubectl apply -f deploy/` once the secret exists — files apply in
alphabetical order, which works fine here.)

Wait for the rollout:

```sh
kubectl -n exstream get pods -w
```

## 4. Reach the app

All traffic enters through Traefik's `web` entrypoint. Depending on how Traefik
is exposed:

```sh
# k3s / LoadBalancer: use the external IP of the traefik service
kubectl -n kube-system get svc traefik

# or port-forward Traefik locally
kubectl -n kube-system port-forward svc/traefik 8080:80
```

Then open http://localhost:8080 — the SPA is served at `/`, the APIs under
`/api/auth`, `/api/playlists`, `/api/music/search`, `/api/file` (Traefik strips
the `/api` prefix before forwarding). The auth service seeds the
`admin`/`admin123` and `test`/`test123` development users on first start
(backed by the `auth-data` volume, so they survive restarts).

Smoke test through the ingress:

```sh
curl -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"test","password":"test123"}'
```

## Scaling notes

- `web` and `forward-auth` are stateless; their HPAs scale 1–5 replicas at
  70% average CPU. Tune `minReplicas`/`maxReplicas` in `hpa.yaml`.
- `auth`, `playlist`, and `file` persist data as flat files on
  `ReadWriteOnce` volumes and use `strategy: Recreate`; keep them at
  **one replica each**. To scale them, move their storage to a shared
  backend (database/object store) first.

## Teardown

```sh
kubectl delete namespace exstream
```

The PVCs (and their data) are deleted with the namespace; back up the volumes
first if you need the libraries to survive.
