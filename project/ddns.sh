sudo -s

mkdir /root/ddns-go
cd /root/ddns-go
cat>get_arch.sh <<EOF
#!/bin/bash

arch=""
get_arch=`arch`
if [[ \$get_arch =~ "x86_64" ]];then
    arch="x86_64"
elif [[ \$get_arch =~ "aarch64" ]];then
    arch="arm64"
elif [[ \$get_arch =~ "mips64" ]];then
    arch="mips64"
else
    arch="unknown"
fi

wget https://github.com/jeessy2/ddns-go/releases/download/v4.2.1/ddns-go_4.2.1_Linux_\${arch}.tar.gz
tar -zxvf ddns-go_4.2.1_Linux_\${arch}.tar.gz
EOF
bash get_arch.sh

cat>/root/.ddns_go_config.yaml <<EOF
ipv4:
    enable: true
    gettype: url
    url: https://ifconfig.me, https://myip4.ipip.net, https://ddns.oray.com/checkip, https://ip.3322.net
    netinterface: ""
    domains:
        - yourddns.ddns.com
ipv6:
    enable: false
    gettype: url
    url: https://myip6.ipip.net, https://speed.neu6.edu.cn/getIP.php, https://v6.ident.me
    netinterface: ""
    ipv6reg: ""
    domains:
        - ""
dns:
    name: dnspod
    id: "yourid"
    secret: yoursecret
user:
    username: yourname
    password: yourpassword
webhook:
    webhookurl: ""
    webhookrequestbody: ""
notallowwanaccess: true
ttl: ""
EOF

sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config 
./ddns-go -s install

