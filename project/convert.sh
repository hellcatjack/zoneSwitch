#!/bin/bash
file='/yourPath/yourList'
serverlist='/yourWWWPath/yourServerList'
serverurl='/yourWWWPath/yourServerURL'
echo -n "" > $serverlist
echo "proxies:" > $serverurl
for line in `cat $file`
do
  echo $line|awk -F ',' '{print $2}'|base64 -d |tr -d \\n  >> $serverlist
  echo "" >> $serverlist
done

for line in `cat $serverlist`
do
  name=`echo $line|awk -F '#' '{print $2}'`
  code=`echo $line|awk -F '#' '{print $1}'|awk -F '/' '{print $3}'|base64 -d |tr -d \\n`
  echo -e -n "- name: $name\n  type: ss\n  cipher: " >> $serverurl
  tmpstr="${code/:/\\n  password%space% }"
  tmpstr="${tmpstr/@/\\n  server%space% }"
  tmpstr="${tmpstr/:/\\n  port%space% }"
  tmpstr="${tmpstr//%space%/:}"
  echo -e "$tmpstr" >> $serverurl
  echo "  udp: true" >> $serverurl
done

/usr/bin/iconv $serverlist -f utf8 -t gbk --output $serverlist
