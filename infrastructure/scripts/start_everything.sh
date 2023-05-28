#!/bin/bash
echo -e "\e[1;42m Creating registry \e[0m"
docker run -d --restart=always -p "127.0.0.1:5000:5000" --name "registry" registry:2
echo -e "\e[1;42m Creating cluster \e[0m"
kind create cluster --image="kindest/node:v1.25.3" --config="infrastructure/kind/nodes_3.yml"
kubectl create ns distributed-storage-system
kubens distributed-storage-system
kubectl apply -f ./infrastructure/registry/config_map.yml
docker network connect "kind" registry
echo -e "\e[1;42m Creating update helm \e[0m"
helm repo add bitnami https://charts.bitnami.com/bitnami
echo -e "\e[1;42m Install istio \e[0m"
istioctl install --set profile=demo -y
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
echo -e "\e[1;42m Sleeping for 60 seconds to install MetalLB\e[0m"
sleep 60s
kubectl apply -f infrastructure/manifests/MetalLb.yaml
kubectl label namespace distributed-storage-system istio-injection=enabled