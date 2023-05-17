#!/bin/bash
ip_address=`kubectl get svc -n istio-system | grep istio-ingressgateway | awk '{print $4}'`
if [ $ip_address = "<pending>" ]
then
    echo "IP address is still in pending"
    exit -1
fi
echo "Getting hosts file"
hosts_entry=`sudo grep "dsm.local" /etc/hosts`
if [ ! -z $hosts_entry ]
then
    sudo sed "s/$hosts_entry/$ip_address dsm.local/g" /etc/hosts 
else
    echo "$ip_address dsm.local" | sudo tee -a /etc/hosts
fi
