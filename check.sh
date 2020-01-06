#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
export TZ=Asia/Shanghai

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: System Checker
#	Version: 1.0.0
#	Author: Hellcat
#=================================================

sh_ver="1.0.0"

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

checkTime(){
	echo && echo -e "${Red_font_prefix}当前时间如下："
	date
	echo && echo -e "${Font_color_suffix}"

	start
}

checkFile(){
	echo && echo -e "${Red_font_prefix}当前路径："`pwd`
        echo && echo -e "${Font_color_suffix}"
	ls -l --color=auto
        start
}

checkPN(){
	check_root
        echo && echo -e "${Red_font_prefix}当前进程如下：${Font_color_suffix}"
        ps aux
        echo && echo -e "${Red_font_prefix}当前端口信息如下："
        echo && echo -e "${Font_color_suffix}"
	netstat -pln
        start	
}

checkFW(){
        check_root
        echo && echo -e "${Red_font_prefix}当前防火墙信息如下："
        echo && echo -e "${Font_color_suffix}"
        iptables -L
        start
}

start(){
echo && echo -e "${Red_font_prefix}------------------------------------${Font_color_suffix}"
check_sys
action=$1
if [[ "${action}" == "monitor" ]]; then
	crontab_monitor
else
	echo && echo -e "  问题排查脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  
————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 查看当前系统时间 
————————————
 ${Green_font_prefix} 2.${Font_color_suffix} 查看当前目录文件
————————————
 ${Green_font_prefix} 3.${Font_color_suffix} 查看进程与端口
————————————
 ${Green_font_prefix} 4.${Font_color_suffix} 查看防火墙策略
————————————" && echo
	echo
	read -e -p " 请输入数字 [0-4]:" num
	case "$num" in
		1)
		checkTime
		;;
		2)
		checkFile
		;;
		3)
		checkPN
		;;
		4)
		checkFW
		;;
		*)
		echo "请输入正确数字 [0-4]"
		start
		;;
	esac
fi
}

start
