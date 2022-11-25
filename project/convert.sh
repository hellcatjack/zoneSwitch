#!/bin/bash
file='/yourPath/yourList'
serverlist='/yourWWWPath/yourServerList'
serverurl='/yourWWWPath/yourServerURL'
echo -n "" > $serverlist
echo -n "" > ${serverlist}_tmp
echo "proxies:" > $serverurl
echo "proxies:" > ${serverurl}hysteria

for line in `cat $file|grep -v '\-hy\-'`
do
  echo $line|awk -F ',' '{print $2}'|base64 -d |tr -d \\n  >> $serverlist
  echo "" >> $serverlist
  echo $line >> ${serverlist}_tmp
done

for line in `cat $file|grep '\-hy\-'`
do
  tmpstr=`echo $line|awk -F ',' '{print $1}'|sed 's/\-hy//g'`,
  if [ `grep -c "$tmpstr" ${serverlist}_tmp` -eq 0 ];then
        echo $line >> ${serverlist}_tmp
  else
        sed -i "/^$tmpstr/c$line" ${serverlist}_tmp
  fi
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

for line in `cat ${serverlist}_tmp`
do
  head=`echo $line|awk -F ',' '{print $1}'`
  noenter=`echo "$line"|awk -F ',' '{print $2}'|base64 -d`
  line=`echo "$line"|awk -F ',' '{print $2}'|base64 -d |tr -d \\\n`
  if [[ $head == *hy* ]];then
	echo -e "$noenter" >> ${serverurl}hysteria
  else
	name=`echo $line|awk -F '#' '{print $2}'`
	code=`echo $line|awk -F '#' '{print $1}'|awk -F '/' '{print $3}'|base64 -d |tr -d \\n`
	echo -e -n "- name: $name\n  type: ss\n  cipher: " >> ${serverurl}hysteria
	tmpstr="${code/:/\\n  password%space% }"
	tmpstr="${tmpstr/@/\\n  server%space% }"
	tmpstr="${tmpstr/:/\\n  port%space% }"
	tmpstr="${tmpstr//%space%/:}"
	echo -e "$tmpstr" >> ${serverurl}hysteria
	echo "  udp: true" >> ${serverurl}hysteria
  fi
done
/usr/bin/iconv $serverlist -f utf8 -t gbk --output $serverlist
