#!/bin/bash
cd istio*
export PATH=$PWD/bin:$PATH
kubectl apply -f samples/addons
cd /
rm -rf istio*
exit