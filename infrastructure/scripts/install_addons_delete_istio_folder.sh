#!/bin/bash
cd istio-1.16.0
export PATH=$PWD/bin:$PATH
kubectl apply -f samples/addons
cd /
rm -rf istio-1.16.0
exit