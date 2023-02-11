#!/bin/bash
kubectl -n ingress-nginx get deploy ingress-nginx-controller -o yaml | /istio-1.16.0/bin/istioctl kube-inject -f - | kubectl apply -f -
kubectl delete po --all -n ingress-nginx
exit 0