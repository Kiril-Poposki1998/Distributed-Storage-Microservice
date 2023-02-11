# Distributed storage system
## Prerequisites
For the project to be deployed locally some tools are needed to be installed.
```
Docker 20.10.21
kind 0.17.0
helm 3.10.1
kubectx 0.9.4
kubens 0.9.4
k9s 0.26.3
skaffold 2.0.2
kubectl 1.25.3
istio 1.16.0
```
## Installing prerequisites (Windows)
The following command needs to be run as administrator in PowerShell.
``` 
choco install packages.config --confirm 
```
## Deploy a registry for the Docker images
```
docker run -d --restart=always -p "127.0.0.1:5000:5000" --name "registry" registry:2
```
## Deploy Kubernetes in Docker with kind
Create and set the context to point to the newly created cluster:
```
kind create cluster --image="kindest/node:v1.25.3" --config="infrastructure\kind\nodes_3.yml"
kubectl cluster-info --context distributed-storage-system
kubectl create ns distributed-storage-system
kubens distributed-storage-system
kubectl apply -f .\infrastructure\registry\config_map.yml
docker network connect "kind" registry
helm repo add bitnami https://charts.bitnami.com/bitnami
```
## Setting up the code for the microservice (Windows)
```
git submodule init
git submodule update
```
### Updating submodules
```
git submodule update --init --recursive --remote
```
## Install istio service mesh and add ingress controller
Install istio with the following commands:
```
docker exec distributed-storage-system-control-plane mkdir /scripts
docker cp .\infrastructure\scripts\install_istio.sh distributed-storage-system-control-plane:/scripts/install_istio.sh
docker exec -i distributed-storage-system-control-plane /scripts/install_istio.sh
```
Install the nginx ingress controller:
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s
docker cp .\infrastructure\scripts\inject_envoy_ingress.sh distributed-storage-system-control-plane:/scripts/inject_envoy_ingress.sh
docker exec -i distributed-storage-system-control-plane /scripts/inject_envoy_ingress.sh
```
## Deploy the microservice to Kubernetes
```
kubectl label namespace distributed-storage-system istio-injection=enabled
skaffold dev
```
**NOTE: The password for the database is password**
## Add monitoring (Optional, recommended for DevOps or analysis)
Add the addons for monitoring 
```
docker cp .\infrastructure\scripts\install_addons_delete_istio_folder.sh distributed-storage-system-control-plane:/scripts/install_addons_delete_istio_folder.sh
docker exec -i distributed-storage-system-control-plane /scripts/install_addons_delete_istio_folder.sh
```
Install the monitoring ingress
```
helm install monitoring-ingress .\infrastructure\helm\helm_monitoring\
```
Add these to your C:\Windows\System32\drivers\etc\hosts file:
```
127.0.0.1 grafana.cluster
127.0.0.1 kiali.cluster
127.0.0.1 prometheus.cluster
127.0.0.1 jaeger.cluster
```
## Deleting cluster
```
kind delete cluster --name=distributed-storage-system
docker rm -f registry
```