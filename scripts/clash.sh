 #!/bin/sh
# Copyright (C) Juewuy

getconfig(){
#版本号
versionsh_l=0.8.6
#服务器地址
if [ ! -n "$update_url" ] && [ ! -z "$update_url" ]; then
	update_url=https://cdn.jsdelivr.net/gh/juewuy/clash-for-Miwifi/
fi
#文件路径
if [ -z $clashdir ];then
clashdir=$(dirname $(readlink -f "$0"))
echo "export clashdir=\"$clashdir\"" >> /etc/profile
fi
ccfg=$clashdir/mark
yaml=$clashdir/config.yaml
#检查标识文件
if [ ! -f "$ccfg" ]; then
	echo mark文件不存在，正在创建！
	cat >$ccfg<<EOF
#标识clash运行状态的文件，不明勿动！
EOF
fi
source $ccfg
#获取自启状态
if [ -f /etc/rc.d/*clash ]; then 
	auto="\033[32m已设置开机启动！\033[0m"
	auto1="\033[36m禁用\033[0mclash开机启动"
else
	auto="\033[31m未设置开机启动！\033[0m"
	auto1="\033[36m允许\033[0mclash开机启动"
fi
#获取运行模式
if [ ! -n "$redir_mod" ]; then
	sed -i "2i\redir_mod=Redir模式" $ccfg
	redir_mod=Redir模式
fi
#获取运行状态
status=`ps |grep -w 'clash -d'|grep -v grep|wc -l`
if [[ $status -gt 0 ]];then
	run="\033[32m正在运行（$redir_mod）\033[0m"
	uid=`ps |grep -w 'clash -d'|grep -v grep|awk '{print $1}'`
	VmRSS=`cat /proc/$uid/status|grep -w VmRSS|awk '{print $2,$3}'`
	#获取运行时长
	if [ -n "$start_time" ]; then 
		time=$((`date +%s`-$start_time))
		day=$(($time/86400))
		if [[ $day != 0 ]]; then 
			day=$day天
		else
			day=""
		fi
		time=`date -u -d @${time} +"%-H小时%-M分%-S秒"`
	fi
else
	run="\033[31m没有运行（$redir_mod）\033[0m"
fi
#输出状态

echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo -e "\033[30;46m欢迎使用Clash for Miwifi！\033[0m"
echo -e "Clash服务"$run"，"$auto""
if [ $status -gt 0 ];then
	echo -e "当前内存占用：\033[44m"$VmRSS"\033[0m，已运行：\033[46;30m"$day"\033[44;37m"$time"\033[0m"
fi
echo -e "我的博客：\033[36;4mjuewuy.xyz\033[0m，交流反馈群：\033[36;4mt.me/clashfm\033[0m"
echo -----------------------------------------------
#安装clash核心
if [ ! -f $clashdir/clash ];then
	echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	echo -e "\033[31m没有找到核心文件，请先下载clash核心！\033[0m"
	source $clashdir/getdate.sh
	getcore
fi
#安装GeoIP数据库
if [ ! -f $clashdir/Country.mmdb ];then
	echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	echo -e "\033[31m没有找到GeoIP数据库文件，请先下载数据库！\033[0m"
	source $clashdir/getdate.sh
	getgeo
fi
}
clashstart(){

/etc/init.d/clash start
sleep 1
status=`ps |grep -w 'clash -d'|grep -v grep|wc -l`
	if [[ $status -gt 0 ]];then
		host=$(ubus call network.interface.lan status | grep \"address\" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}';)
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "\033[32mclash服务已启动！\033[0m"
		echo -e "可以使用\033[30;47m http://clash.razord.top \033[0m管理内置规则"
		echo -e "也可以前往更新菜单安装本地Dashboard面板，连接更稳定！！！"
		echo -e "Host地址:\033[36m $host \033[0m 端口:\033[36m 9999 \033[0m"
	else
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "\033[31mclash服务启动失败！请检查配置文件！\033[0m"
	fi
}
clashlink(){
#获取订阅规则
if [ ! -n "$rule_link" ]; then
	sed -i '/rule_link=*/'d $ccfg
	sed -i "4i\rule_link=1" $ccfg
	rule_link=1
fi
#获取后端服务器地址
if [ ! -n "$server_link" ]; then
	sed -i '/server_link=*/'d $ccfg
	sed -i "5i\server_link=1" $ccfg
	server_link=1
fi
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo -e "\033[30;47m 欢迎使用订阅功能！\033[0m"
echo -----------------------------------------------
echo -e " 1 输入\033[36m节点/订阅\033[0m链接"
echo -e " 2 输入完整clash规则链接"
echo -e " 3 选取\033[33m代理规则\033[0m模版"
echo -e " 4 选择配置生成服务器"
echo -e " 5 \033[36m还原\033[0m配置文件"
echo -e " 6 \033[32m手动更新\033[0m订阅"
echo -e " 7 设置自动更新（未完成）"
echo -e " 0 返回上级菜单"
read -p "请输入对应数字 > " num
if [ -z $num ];then
	echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	echo -e "\033[31m请输入正确的数字！\033[0m"
	clashsh
elif [[ $num == 1 ]];then
	if [ -n "$Url" ];then
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "\033[33m检测到已记录的订阅链接：\033[0m"
		echo -e "\033[4;32m$Url\033[0m"
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		read -p "清空链接/追加导入？[1/0] > " res
		if [ "$res" = '1' ]; then
			Url=""
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			echo -e "\033[31m链接已清空！\033[0m"
		fi
	fi
	source $clashdir/getdate.sh
	getlink
  
elif [[ $num == 2 ]];then
	if [ -n "$Url" ];then
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "\033[33m检测到已记录的订阅链接：\033[0m"
		echo -e "\033[4;32m$Url\033[0m"
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		read -p "清空链接/追加导入？[1/0] > " res
		if [ "$res" = '1' ]; then
			Url=""
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			echo -e "\033[31m链接已清空！\033[0m"
		fi
	fi
	source $clashdir/getdate.sh
	getlink2
elif [[ $num == 3 ]];then
	echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	echo -e "\033[44m 实验性功能，遇问题请加TG群反馈：\033[42;30m t.me/clashfm \033[0m"
	echo 当前使用规则为：$rule_link
	echo 1 ACL4SSR默认通用版（推荐）
	echo 2 ACL4SSR精简全能版（推荐）
	echo 3 ACL4SSR通用版去广告加强
	echo 4 ACL4SSR精简版去广告加强
	echo 5 ACL4SSR通用版无去广告
	echo 0 返回上级菜单
	read -p "请输入对应数字 > " num
		if [ -z $num ];then
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "\033[31m请输入正确的数字！\033[0m"
		clashlink
		else
			#将对应标记值写入mark
			sed -i '/rule_link*/'d $ccfg
			sed -i "4i\rule_link="$num"" $ccfg	
			rule_link=$num
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	  
			echo -e "\033[32m设置成功！返回上级菜单！\033[0m"
			clashlink
		fi
elif [[ $num == 4 ]];then
	echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	echo -e "\033[44m 实验性功能，遇问题请加TG群反馈：\033[42;30m t.me/clashfm \033[0m"
	echo 当前使用后端为：$server_link
	echo 1 subconverter-web.now.sh
	echo 2 subconverter.herokuapp.com
	echo 3 subcon.py6.pw
	echo 4 api.dler.io
	echo 5 api.wcc.best
	echo 6 skapi.cool
	echo 7 subconvert.dreamcloud.pw
	echo 0 返回上级菜单
	read -p "请输入对应数字 > " num
    if [ -z $num ];then
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "\033[31m请输入正确的数字！\033[0m"
		clashlink
	else
		if [[ $num == 0 ]];then
		clashlink
		fi
		#将对应标记值写入mark
		sed -i '/server_link*/'d $ccfg
		sed -i "4i\server_link="$num"" $ccfg	
		server_link=$num
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	  
		echo -e "\033[32m设置成功！返回上级菜单！\033[0m"
		clashlink
	fi
elif [[ $num == 5 ]];then
	yamlbak=$yaml.bak
	if [ ! -f "$yaml".bak ];then
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "\033[31m没有找到配置文件的备份！\033[0m"
	else
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e 备份文件共有"\033[32m`wc -l < $yamlbak`\033[0m"行内容，当前文件共有"\033[32m`wc -l < $yaml`\033[0m"行内容
		read -p "确认还原配置文件？此操作不可逆！[1/0] > " res
		if [ "$res" = '1' ]; then
			mv $yamlbak $yaml
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			echo -e "\033[32m配置文件已还原！请手动重启clash服务！\033[0m"
		else 
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			echo -e "\033[31m操作已取消！返回上级菜单！\033[0m"
		fi
	fi
	clashsh
elif [[ $num == 6 ]];then
	if [ ! -n "$Url" ];then
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo 没有找到你的订阅链接！请先输入链接！
		clashlink
	else
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "\033[33m当前系统记录的订阅链接为：\033[0m"
		echo -e "\033[4;32m$Url\033[0m"
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		read -p "确认更新配置文件？[1/0] > " res
		if [ "$res" = '1' ]; then
			source $clashdir/getdate.sh
			getyaml
		fi
			clashlink
	fi
elif [[ $num == 0 ]];then
	clashsh
else
	echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	echo -e "\033[31m请输入正确的数字！\033[0m"
	exit;
fi
}
clashadv(){
#获取设置默认显示
if [ ! -n "$skip_cert" ]; then
	skip_cert=已开启
fi
if [ ! -n "$common_ports" ]; then
	common_ports=未开启
fi
if [ ! -n "$dns_mod" ]; then
	dns_mod=redir_host
fi
if [ ! -n "$modify_yaml" ]; then
	modify_yaml=未开启
fi
if [ ! -n "$ipv6_support" ]; then
	ipv6_support=未开启
fi
#
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo -e "\033[30;47m欢迎使用高级模式菜单：\033[0m"
echo -e "\033[33m修改配置后请手动重启clash服务！\033[0m"
echo -----------------------------------------------
echo -e " 1 切换Clash运行模式: 	\033[36m$redir_mod\033[0m"
echo -e " 2 切换DNS运行模式：	\033[36m$dns_mod\033[0m"
echo -e " 3 跳过本地证书验证：	\033[36m$skip_cert\033[0m   ————解决节点证书验证错误"
echo -e " 4 只代理常用端口： 	\033[36m$common_ports\033[0m   ————用于屏蔽P2P流量"
echo -e " 5 不修饰config.yaml:	\033[36m$modify_yaml\033[0m   ————用于使用自定义配置"
echo -e " 6 启用ipv6支持:     	\033[36m$ipv6_support\033[0m   ————实验性且不兼容Fake_ip"
echo -e " 9 \033[32m重启\033[0mclash服务"
echo -e " 0 返回上级菜单 \033[0m"
read -p "请输入对应数字 > " num
if [[ $num -le 9 ]] > /dev/null 2>&1; then 
	if [[ $num == 0 ]]; then
		clashsh  
	elif [[ $num == 1 ]]; then
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "当前代理模式为：\033[47;30m $redir_mod \033[0m；Clash核心为：\033[47;30m $clashcore \033[0m"
		echo -e "\033[33m切换模式后需要手动重启clash服务以生效！\033[0m"
		echo -e "\033[36mTun及混合模式必须使用clashpre核心！\033[0m"
		echo -----------------------------------------------
		echo " 1 Redir模式：CPU以及内存占用较低"
		echo "              但不支持UDP流量转发"
		echo "              日常使用推荐此模式"
		echo " 2 Tun模式：  支持UDP转发且延迟低"
		echo "              但CPU及内存占用更高"
		echo "              且不支持redir-host"
		echo " 3 混合模式： 仅使用Tun转发UPD流量"
		echo "              CPU和内存占用较高"
		echo "              不推荐使用redir-host"
		echo " 0 返回上级菜单"
		read -p "请输入对应数字 > " num	
		if [ -z $num ]; then
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			echo -e "\033[31m请输入正确的数字！\033[0m"
			clashadv
		elif [[ $num == 0 ]]; then
			clashadv
		elif [[ $num == 1 ]]; then
			redir_mod=Redir模式
		elif [[ $num == 2 ]]; then
			if [ "$clashcore" = "clash" ] || [ "$clashcore" = "clashr" ];then
				echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				echo -e "\033[31m当前核心不支持开启Tun模式！请先切换clash核心！！！\033[0m"
				clashadv
			fi
			redir_mod=Tun模式
			dns_mod=fake-ip
		elif [[ $num == 3 ]]; then
			if [ "$clashcore" = "clash" ] || [ "$clashcore" = "clashr" ];then
				echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				echo -e "\033[31m当前核心不支持开启Tun模式！请先切换clash核心！！！\033[0m"
				clashadv
			fi
			redir_mod=混合模式		
		else
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			echo -e "\033[31m请输入正确的数字！\033[0m"
			clashadv
		fi
		sed -i '/redir_mod*/'d $ccfg
		sed -i "1i\redir_mod=$redir_mod" $ccfg
		sed -i '/dns_mod*/'d $ccfg
		sed -i "1i\dns_mod=$dns_mod" $ccfg
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
		echo -e "\033[36m已设为 $redir_mod ！！\033[0m"
		clashadv
	  
	elif [[ $num == 2 ]]; then
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "当前DNS运行模式为：\033[47;30m $dns_mod \033[0m"
		echo -e "\033[33m切换模式后需要手动重启clash服务以生效！\033[0m"
		echo -----------------------------------------------
		echo " 1 fake-ip模式：   响应速度更快"
		echo "                   但可能和部分软件有冲突"
		echo " 2 redir_host模式：使用稳定，兼容性好"
		echo "                   不支持Tun模式"
		echo " 0 返回上级菜单"
		read -p "请输入对应数字 > " num
		if [ -z $num ]; then
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			echo -e "\033[31m请输入正确的数字！\033[0m"
			clashadv
		elif [[ $num == 0 ]]; then
			clashadv
		elif [[ $num == 1 ]]; then
			dns_mod=fake-ip
		elif [[ $num == 2 ]]; then
			dns_mod=redir_host
			redir_mod=Redir模式
		else
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			echo -e "\033[31m请输入正确的数字！\033[0m"
			clashadv
		fi
		sed -i '/dns_mod*/'d $ccfg
		sed -i "1i\dns_mod=$dns_mod" $ccfg
		sed -i '/redir_mod*/'d $ccfg
		sed -i "1i\redir_mod=$redir_mod" $ccfg
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
		echo -e "\033[36m已设为 $dns_mod 模式！！\033[0m"
		clashadv
	
	elif [[ $num == 3 ]]; then	
		sed -i '/skip_cert*/'d $ccfg
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if [ "$skip_cert" = "未开启" ] > /dev/null 2>&1; then 
			sed -i "1i\skip_cert=已开启" $ccfg
			echo -e "\033[33m已设为开启跳过本地证书验证！！\033[0m"
			skip_cert=已开启
		else
			/etc/init.d/clash enable
			sed -i "1i\skip_cert=未开启" $ccfg
			echo -e "\033[33m已设为禁止跳过本地证书验证！！\033[0m"
			skip_cert=未开启
		fi
		clashadv
	
	elif [[ $num == 4 ]]; then	
		sed -i '/common_ports*/'d $ccfg
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if [ "$common_ports" = "未开启" ] > /dev/null 2>&1; then 
			sed -i "1i\common_ports=已开启" $ccfg
			echo -e "\033[33m已设为仅代理（22,53,587,465,995,993,143,80,443）等常用端口！！\033[0m"
			common_ports=已开启
		else
			/etc/init.d/clash enable
			sed -i "1i\common_ports=未开启" $ccfg
			echo -e "\033[33m已设为代理全部端口！！\033[0m"
			common_ports=未开启
		fi
		clashadv  
	
	elif [[ $num == 5 ]]; then	
		sed -i '/modify_yaml*/'d $ccfg
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if [ "$modify_yaml" = "未开启" ] > /dev/null 2>&1; then 
			sed -i "1i\modify_yaml=已开启" $ccfg
			echo -e "\033[33m已设为使用用户完成自定义配置文件！！"
			echo -e "\033[0m不明白原理的用户切勿随意开启此选项"
			echo -e "\033[33m！！！必然会导致上不了网！！!\033[0m"
			modify_yaml=已开启
		else
			/etc/init.d/clash enable
			sed -i "1i\modify_yaml=未开启" $ccfg
			echo -e "\033[32m已设为使用脚本内置规则管理config.yaml配置文件！！\033[0m"
			modify_yaml=未开启
		fi
		clashadv  
		
	elif [[ $num == 6 ]]; then	
		sed -i '/ipv6_support*/'d $ccfg
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if [ "$ipv6_support" = "未开启" ] > /dev/null 2>&1; then 
			sed -i "1i\ipv6_support=已开启" $ccfg
			echo -e "\033[33m已开启对ipv6协议的支持！！\033[0m"
			echo -e "Clash对ipv6的支持并不友好，如不能使用请静等修复！"
			ipv6_support=已开启
		else
			/etc/init.d/clash enable
			sed -i "1i\ipv6_support=未开启" $ccfg
			echo -e "\033[32m已禁用对ipv6协议的支持！！\033[0m"
			ipv6_support=未开启
		fi
		clashadv  
	
	elif [[ $num == 9 ]]; then	
		if [ $status -gt 0 ];then
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			/etc/init.d/clash stop
			echo -e "\033[31mClash服务已停止！\033[0m"
		fi
		clashstart
		clashsh
	else
		echo -e "\033[31m暂未支持的选项！\033[0m"
		clashadv
	fi
else
	echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	echo -e "\033[31m请输入正确的数字！\033[0m"
	clashsh
fi
exit;
}
update(){
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo -e "\033[30;47m欢迎使用更新功能：\033[0m"
echo -e "感谢：\033[32mClash \033[0m作者\033[36m Dreamacro\033[0m 项目地址：\033[32mhttps://github.com/Dreamacro/clash\033[0m"
echo -e "感谢：\033[32mClashR \033[0m作者\033[36m BROBIRD\033[0m 项目地址：\033[32mhttps://github.com/BROBIRD/clash\033[0m"
echo -e "感谢：\033[32m更多的帮助过我的人！\033[0m"
echo -----------------------------------------------
echo -e " 1 更新\033[36m管理脚本\033[0m"
echo -e " 2 切换\033[33mclash核心\033[0m"
echo -e " 3 更新\033[32mGeoIP数据库\033[0m"
echo -e " 4 安装本地\033[35mDashboard\033[0m面板"
echo -e " 8 切换\033[36m安装源\033[0m地址"
echo -e " 9 \033[31m卸载\033[34mClash for Miwfi\033[0m"
echo -e " 0 返回上级菜单" 
read -p "请输入对应数字 > " num
if [[ $num -le 9 ]] > /dev/null 2>&1; then 
	if [[ $num == 0 ]]; then
		clashsh
	
	elif [[ $num == 1 ]]; then	
		source $clashdir/getdate.sh
		getsh	
	
	elif [[ $num == 2 ]]; then	
		source $clashdir/getdate.sh
		getcore

	elif [[ $num == 3 ]]; then	
		source $clashdir/getdate.sh
		getgeo
	
	elif [[ $num == 4 ]]; then	
		source $clashdir/getdate.sh
		getdb
		
	elif [[ $num == 8 ]]; then	
		source $clashdir/getdate.sh
		setserver
		
	elif [[ $num == 9 ]]; then
		read -p "确认卸载clash？（警告：该操作不可逆！）[1/0] " res
		if [ "$res" = '1' ]; then
			/etc/init.d/clash disable
			/etc/init.d/clash stop
			rm -rf $clashdir
			rm -rf /etc/init.d/clash
			rm -rf /www/clash
			rm -rf $csh
			sed -i '/alias clash=*/'d /etc/profile
			sed -i '/export clashdir=*/'d /etc/profile
			echo 已卸载clash相关文件！
		fi
		echo -e "\033[31m操作已取消！\033[0m"
		exit;
	else
		echo -e "\033[31m暂未支持的选项！\033[0m"
		update
	fi
else
	echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	echo -e "\033[31m请输入正确的数字！\033[0m"
	clashsh
fi
exit;
}
clashsh(){
#############################
getconfig
#############################
echo -e " 1 \033[32m启动/重启\033[0mclash服务"
echo -e " 2 clash\033[33m高级设置\033[0m"
echo -e " 3 \033[31m停止\033[0mclash服务"
echo -e " 4 $auto1"
echo -e " 5 设置定时任务（施工中）"
echo -e " 6 导入\033[32m节点/订阅\033[0m链接"
echo -e " 8 \033[35m测试菜单\033[0m"
echo -e " 9 \033[36m更新/卸载\033[0m"
echo -e " 0 \033[0m退出脚本\033[0m"
read -p "请输入对应数字 > " num
if [[ $num -le 9 ]] > /dev/null 2>&1; then 
	if [[ $num == 0 ]]; then
		exit;
  
	elif [[ $num == 1 ]]; then
		if [ ! -f "$yaml" ];then
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			echo -e "\033[31m没有找到配置文件，请先导入节点/订阅链接！\033[0m"
			clashlink
		fi
		if [ $status -gt 0 ];then
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			/etc/init.d/clash stop > /dev/null 2>&1
			echo -e "\033[31mClash服务已停止！\033[0m"
		fi
		clashstart
		clashsh
  
	elif [[ $num == 2 ]]; then
		clashadv

	elif [[ $num == 3 ]]; then
		/etc/init.d/clash stop > /dev/null 2>&1
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "\033[31mClash服务已停止！\033[0m"
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		exit;

	elif [[ $num == 4 ]]; then
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if [ -f /etc/rc.d/*clash ]; then
			/etc/init.d/clash disable
			echo -e "\033[33m已禁止Clash开机启动！\033[0m"
		else
			/etc/init.d/clash enable
			echo -e "\033[32m已设置Clash开机启动！\033[0m"
		fi
		clashsh

	elif [[ $num == 5 ]]; then
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "\033[31m正在施工中，敬请期待！\033[0m"
		echo -e "\033[32m正在施工中，敬请期待！\033[0m"
		echo -e "\033[33m正在施工中，敬请期待！\033[0m"
		echo -e "\033[34m正在施工中，敬请期待！\033[0m"
		echo -e "\033[35m正在施工中，敬请期待！\033[0m"
		echo -e "\033[36m正在施工中，敬请期待！\033[0m"
		clashsh
    
	elif [[ $num == 6 ]]; then
		clashlink

	elif [[ $num == 8 ]]; then
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "\033[30;47m这里是测试命令菜单\033[0m"
		echo -e "\033[33m如遇问题尽量运行相应命令后截图发群\033[0m"
		echo -----------------------------------------------
		echo " 1 查看clash运行时的报错信息"
		echo " 2 查看系统DNS端口(:53)占用 "
		echo " 3 测试ssl加密（aes-128-gcm）跑分"
		echo " 4 查看iptables端口转发详情"
		echo " 5 查看config.yaml前40行"
		echo " 6 测试代理服务器连通性（google.tw)"
		echo " 0 返回上级目录！"
		read -p "请输入对应数字 > " num
		if [ -z $num ]; then
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			echo -e "\033[31m请输入正确的数字！\033[0m"
			clashsh
		elif [[ $num == 0 ]]; then
			clashsh
		elif [[ $num == 1 ]]; then
			etc/init.d/clash stop
			echo -e "\033[31m如有报错请截图后到TG群询问！！！\033[0m"
			$clashdir/clash -d $clashdir & { sleep 3 ; kill $! & }
			echo -e "\033[31m如有报错请截图后到TG群询问！！！\033[0m"
			exit;
		elif [[ $num == 2 ]]; then
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			netstat -ntulp |grep 53
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			exit;
		elif [[ $num == 3 ]]; then
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			openssl speed -multi 4 -evp aes-128-gcm
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			exit;
		elif [[ $num == 4 ]]; then
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			iptables  -t nat  -L PREROUTING --line-numbers
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			exit;
		elif [[ $num == 5 ]]; then
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			sed -n '1,40p' $yaml
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			exit;
		elif [[ $num == 6 ]]; then
			echo 注意：测试结果不保证一定准确！
			delay=`curl -kx 127.0.0.1:7890 -o /dev/null -s -w '%{time_starttransfer}' 'https://google.tw' & { sleep 3 ; kill $! & }` > /dev/null 2>&1
			delay=`echo |awk "{print $delay*1000}"` > /dev/null 2>&1
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if [ `echo ${#delay}` -gt 1 ];then
				echo -e "\033[32m连接成功！响应时间为："$delay" ms\033[0m"
			else
				echo -e "\033[31m连接超时！请重试或检查节点配置！\033[0m"
			fi
			clashsh
		else
			echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			echo -e "\033[31m请输入正确的数字！\033[0m"
			clashsh
		fi

	elif [[ $num == 9 ]]; then
		update
	
	else
		echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		echo -e "\033[31m请输入正确的数字！\033[0m"
	fi
	exit 1
else
	echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	echo -e "\033[31m请输入正确的数字！\033[0m"
fi
exit 1
}
clashsh