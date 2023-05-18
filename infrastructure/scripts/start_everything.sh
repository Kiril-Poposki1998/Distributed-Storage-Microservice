#!/bin/bash
docker run -d --restart=always -p "127.0.0.1:5000:5000" --name "registry" registry:2
kind create cluster --image="kindest/node:v1.25.3" --config="infrastructure/kind/nodes_3.yml"
kubectl cluster-info --context distributed-storage-system
kubectl create ns distributed-storage-system
kubens distributed-storage-system
kubectl apply -f ./infrastructure/registry/config_map.yml
docker network connect "kind" registry
helm repo add bitnami https://charts.bitnami.com/bitnami
istioctl install --set profile=demo -y
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
echo "Sleeping for 30 seconds to install MetalLB"
sleep 30s
kubectl apply -f infrastructure/manifests/MetalLb.yaml
kubectl label namespace distributed-storage-system istio-injection=enabled