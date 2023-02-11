#!/bin/bash
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.16.0
export PATH=$PWD/bin:$PATH
istioctl install --set profile=demo -y
exit 0