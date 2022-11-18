#!/bin/bash
server=`hostname`
name=YourServerName
ip=`curl -s ifconfig.me`
reqServer=https://yourServer/req

count=1
for line in `find /etc/shadowsocks-libev -name *.json`
do
        method=`cat $line|grep method|awk -F '"' '{print $4}'`
        pwd=`cat $line|grep password|awk -F '"' '{print $4}'`
        port=`cat $line|grep port|awk -F ':' '{print $2}' |awk -F ',' '{print $1}'`
        url=`echo "$method:$pwd@$ip:$port"|base64 -w 0`
        url=`echo "ss://$( base64 <<< $method:$pwd@$ip:$port )#$name"|base64 -w 0`
        echo `curl -s --data-urlencode "ps=$url" --data-urlencode "keyword=$server-$count" $reqServer`
        count=$((${count} + 1))
done
