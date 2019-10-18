#!/bin/bash

if [ $1 = "local" ]; then
	newIP="1.1.1.1"

else
	if [ ${#1} -gt 4 ]; then
	        echo "Zonename is too long!"
	        exit 1
	fi
	
	domain=${1}.steamsv.top
	newIP=`dig +short $domain`

	if [ ${#newIP} -lt 7 ]; then
	        echo "Zonename is incorrect!"
	        exit 1
	fi
fi

echo "The Server has switched to $1 [$newIP]."
sed -i "s/\(.*\)\/.*/\1\/$newIP/g" /etc/dnsmasq.d/zoneSwitch.conf 
sleep 1s
systemctl restart dnsmasq
