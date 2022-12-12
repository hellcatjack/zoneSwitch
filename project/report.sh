#!/bin/bash
config=/root/config_report.sh
source $config
ip1=`curl -s ifconfig.me`
ip2=`curl -s myip.ipip.net|grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"`
up=30
down=200

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

count=1
lasturlsplit=(${lasturl//\;/ })
newurl=""
for line in `find /etc/shadowsocks* -name *.json`
do
        method=`cat $line|grep method|awk -F '"' '{print $4}'`
        pwd=`cat $line|grep password|awk -F '"' '{print $4}'`
        port=`cat $line|grep port|awk -F ':' '{print $2}' |awk -F ',' '{print $1}'`
        url=`echo "$method:$pwd@$ip:$port"|base64 -w 0`
        url=`echo "ss://$( base64 <<< $method:$pwd@$ip:$port )#$name"|base64 -w 0`
	newurl="$newurl$url;"
	
	if [ "$url" == "${lasturlsplit[$[ count -1 ]]}" ]; then
	        echo "URL$count has not changed."
	else
	        md5=`echo -n $server-${count}$md5key$url|md5sum|cut -d ' ' -f1`
	        result=`curl -s --data-urlencode "ps=$url" --data-urlencode "keyword=$server-$count" --data-urlencode "md5=$md5" $reqServer`
	fi
        count=$((${count} + 1))
done

count=1
lasthysteriasplit=(${lasthysteria//\;/ })
newhyurl=""

for line in `find /etc/hysteria -name *.json`
do
        protocol=`cat $line|grep protocol|awk -F '"' '{print $4}'`
        obfs=`cat $line|grep obfs|awk -F '"' '{print $4}'`
        alpn=`cat $line|grep alpn|awk -F '"' '{print $4}'`
#        up=`cat $line|grep up_mbps|awk -F ':' '{print $2}'|awk -F ',' '{print $1}'|sed 's/^[ \t]*//g'`
#        down=`cat $line|grep down_mbps|awk -F ':' '{print $2}'|awk -F ',' '{print $1}'|sed 's/^[ \t]*//g'`
        pwd=`cat $line|grep config|awk -F '"' '{print $4}'`
        port=`cat $line|grep listen|awk -F ':' '{print $3}' |awk -F '"' '{print $1}'`
	port=$((${port} + 1))
        url=`echo -e "- name: $name\n  server: $ip\n  port: $port\n  type: hysteria\n  protocol: $protocol\n  up: $up\n  down: $down\n  alpn:\n  - $alpn\n  auth_str: $pwd\n  obfs: $obfs"`
        url=`echo "$url"|base64 -w 0`
        newhyurl="$newhyurl$url;"

        if [ "$url" == "${lasthysteriasplit[$[ count -1 ]]}" ]; then
                echo "Hysteria config$count has not changed."
        else
                md5=`echo -n $server-hy-${count}$md5key$url|md5sum|cut -d ' ' -f1`
                result=`curl -s --data-urlencode "ps=$url" --data-urlencode "keyword=$server-hy-$count" --data-urlencode "md5=$md5" $reqServer`
        fi
        count=$((${count} + 1))
done

if [ -z "$(echo "$result")" ]; then
        echo "No updates are required."
elif [ "$result" == '{"result": 0}' ]; then
	echo "Submit success."
	sed -i "/^lasturl=/clasturl=\"$newurl\"" $config
	sed -i "/^lasthysteria=/clasthysteria=\"$newhyurl\"" $config
else
	echo "Submit failure."
	exit 1
fi

exit 0
