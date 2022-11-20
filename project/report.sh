#!/bin/bash
server=`hostname`
name=YourServerName
reqServer=yourReqestServer
md5key=yourMD5KEY
lastip=/root/lastip
ip1=`curl -s ifconfig.me`
ip2=`curl -s myip.ipip.net|grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"`

function isValidIp() {
        local ip=$1
        local ret=1
        if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                ip=(${ip//\./ }) # 按.分割，转成数组，方便下面的判断
                [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
                ret=$?
        fi
        return $ret
}

echo Checking first ipaddress [$ip1]...
isValidIp $ip1
if [ $? -ne  0 ];then
	echo "Error! Try second ipaddress [$ip2]..."
	isValidIp $ip2
	if [ $? -ne 0 ];then
		echo "Error! Can't get ipaddress. Exiting..."
		exit 1
	fi
	ip=$ip2
else
	ip=$ip1
fi
echo "Pass! [$ip]"

lastsubmitip=`cat $lastip`
if [ "$ip" == "$lastsubmitip" ]; then
	echo "IP is not change. Exiting..."
	exit 1
fi

count=1
result=''
for line in `find /etc/shadowsocks-libev -name *.json`
do
        method=`cat $line|grep method|awk -F '"' '{print $4}'`
        pwd=`cat $line|grep password|awk -F '"' '{print $4}'`
        port=`cat $line|grep port|awk -F ':' '{print $2}' |awk -F ',' '{print $1}'`
        url=`echo "$method:$pwd@$ip:$port"|base64 -w 0`
        url=`echo "ss://$( base64 <<< $method:$pwd@$ip:$port )#$name"|base64 -w 0`
        md5=`echo -n $server-${count}$md5key$url|md5sum|cut -d ' ' -f1`
	result=`curl -s --data-urlencode "ps=$url" --data-urlencode "keyword=$server-$count" --data-urlencode "md5=$md5" $reqServer`
        count=$((${count} + 1))
done

if [ $result == '{"result":0}' ]; then
	echo "Submit success."
	echo -n $ip > $lastip
	exit 0
else
	echo "Submit failure."
	exit 1
fi
