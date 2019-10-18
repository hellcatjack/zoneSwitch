#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: zoneSwitch Installer
#	Version: 1.0.0
#	Author: Jack Xiang
#=================================================

sh_ver="1.0.0"
filepath=$(cd "$(dirname "$0")"; pwd)
file_1=$(echo -e "${filepath}"|awk -F "$0" '{print $1}')
FOLDER="/usr/local/shadowsocks-go"
FILE="${filepath}/zoneSwitch/start.sh"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}
#检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}
check_installed_status(){
	[[ ! -e ${FILE} ]] && echo -e "${Error} zoneSwitch 没有安装，请检查 !" && exit 1
}
check_crontab_installed_status(){
	if [[ ! -e ${Crontab_file} ]]; then
		echo -e "${Error} Crontab 没有安装，开始安装..."
		if [[ ${release} == "centos" ]]; then
			yum install crond -y
		else
			apt-get install cron -y
		fi
		if [[ ! -e ${Crontab_file} ]]; then
			echo -e "${Error} Crontab 安装失败，请检查！" && exit 1
		else
			echo -e "${Info} Crontab 安装成功！"
		fi
	fi
}
check_pid(){
	PID=$(ps -ef| grep "flask run"| grep -v "grep" | grep -v "init.d" |grep -v "service" |awk '{print $2}')
}
Install(){
        check_root
        [[ -e ${FILE} ]] && echo -e "${Error} 检测到 zoneSwitch 已安装 !" && exit 1
        echo -e "${Info} 开始安装..."
	if [[ ${release} == "centos" ]]; then
        	yum install git net-tools bind-utils dnsmasq python3-pip -y
        else
        	apt-get install git net-tools bind-utils dnsmasq python3-pip -y
        fi
	pip3 install flask_sqlalchemy flask-login
	git clone https://github.com/hellcatjack/zoneSwitch.git
	iptables -I INPUT -p tcp --dport 5000 -j ACCEPT
	cp zoneSwitch/dnsmasq.conf /etc/dnsmasq.d/zoneSwitch.conf
	systemctl restart dnsmasq
	systemctl enable dnsmasq
	chmod +x zoneSwitch/start.sh
        echo -e "${Info} 所有步骤 安装完毕，开始启动..."
	filepathtmp=${filepath//\//\\\/}
	sed -i "s/cd ~\/zoneswitch/cd ${filepathtmp}\/zoneSwitch/g" zoneSwitch/start.sh 
	Start
	createuser
}

Start(){
	zoneSwitch/start.sh
}

Restart(){
	check_installed_status
	check_pid
	zoneSwitch/start.sh
	#sleep 1s
	check_pid
	[[ ! -z ${PID} ]] && echo -e "zoneSwitch 重启完成 !"
	
}

createuser(){
        check_installed_status
        echo && echo -e "请输入邮箱：（用于登录）" && echo
        read -e -p "(默认: admin@admin.com):" username
        [[ -z "${username}" ]] && username="admin@admin.com"

        echo && echo -e "请输入昵称：（用于显示）" && echo
        read -e -p "(默认: admin):" nickname
        [[ -z "${nickname}" ]] && nickname="admin"

        echo && echo -e "请输入密码：（用于登录）" && echo
        read -e -p "(默认: admin):" pwd
        [[ -z "${pwd}" ]] && pwd="admin"

	cd zoneSwitch/project && python3 createuser.py $username $nickname $pwd

}


check_sys
action=$1
if [[ "${action}" == "monitor" ]]; then
	crontab_monitor
else
	echo && echo -e "  zoneSwitch 一键管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  ---- Jack Xiang ----
  
————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 安装 zoneSwitch
————————————
 ${Green_font_prefix} 2.${Font_color_suffix} 重启 zoneSwitch
————————————
 ${Green_font_prefix} 3.${Font_color_suffix} 设置 账号配置
————————————" && echo
	if [[ -e ${FILE} ]]; then
		check_pid
		if [[ ! -z "${PID}" ]]; then
			echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix}"
		else
			echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
		fi
	else
		echo -e " 当前状态: ${Red_font_prefix}未安装${Font_color_suffix}"
	fi
	echo
	read -e -p " 请输入数字 [0-10]:" num
	case "$num" in
		1)
		Install
		;;
		2)
		Restart
		;;
		3)
		createuser
		;;
		*)
		echo "请输入正确数字 [0-3]"
		;;
	esac
fi
