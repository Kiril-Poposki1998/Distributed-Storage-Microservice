# Distributed storage system
## Prerequisites
For the project to be deployed locally some tools are needed to be installed and this is going to be done through <b>asdf</b>.

Use asdf to install them:
```
asdf install
```
## Deploy a registry for the Docker images
```
docker run -d --restart=always -p "127.0.0.1:5000:5000" --name "registry" registry:2
```
## Deploy Kubernetes in Docker with kind
Create and set the context to point to the newly created cluster:
```
kind create cluster --image="kindest/node:v1.25.3" --config="infrastructure/kind/nodes_3.yml"
kubectl cluster-info --context distributed-storage-system
kubectl create ns distributed-storage-system
kubens distributed-storage-system
kubectl apply -f ./infrastructure/registry/config_map.yml
docker network connect "kind" registry
helm repo add bitnami https://charts.bitnami.com/bitnami
```
## Setting up the code for the microservice (Windows)
```
git submodule init
git submodule update
```
## Install istio service mesh and add ingress controller
Install istio with the following commands:
```
istioctl install --set profile=demo -y
```
or
```
docker exec distributed-storage-system-control-plane mkdir /scripts
docker cp ./infrastructure/scripts/install_istio.sh distributed-storage-system-control-plane:/scripts/install_istio.sh
docker exec -i distributed-storage-system-control-plane /scripts/install_istio.sh
```
Add MetalLB CRDs and install configuration:
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
kubectl apply -f infrastructure/manifests/MetalLb.yaml
```
## Add IP address to hosts file
```
bash ./infrastructure/scripts/IP_to_hosts.sh 
```
## Deploy the microservice to Kubernetes
```
kubectl label namespace distributed-storage-system istio-injection=enabled
skaffold dev
```
## Add monitoring (Optional, recommended for DevOps or analysis)
Add the addons for monitoring 
```
kubectl apply -f ./infrastructure/manifests/monitoring/
```
Access the monitoring services with istio
```
istioctl dashboard kiali
istioctl dashboard grafana
istioctl dashboard jaeger
istioctl dashboard prometheus
```
## Deleting cluster
```
kind delete cluster --name=distributed-storage-system
docker rm -f registry
```