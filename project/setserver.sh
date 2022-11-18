#!/bin/bash
file='/yourPath/yourList'
serverlist='/yourPath/yourServerList'
keyword=`echo $1|awk -F '#' '{print $1}'`
ps=`echo $1|awk -F '#' '{print $2}'`

if [ `grep -c "$keyword" $file` -eq 0 ];then
        echo $keyword,$ps >> $file
else
        sed -i "/^$keyword,/c$keyword,$ps" $file
fi
