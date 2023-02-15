#!/bin/bash
kubectl -n ingress-nginx get deploy ingress-nginx-controller -o yaml | /istio*/bin/istioctl kube-inject -f - | kubectl apply -f -
kubectl delete po --all -n ingress-nginx
exit 0