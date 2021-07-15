#!/usr/bin/bash
#Description: Install Nginx
#Author: lei
#CreateTime: 2021-7-14

##var

#下载地址和版本名
downloadUrl="http://nginx.org/download/nginx-1.20.1.tar.gz"
packageName="nginx-1.20.1"
#编译目录
installPosition="/usr/local/nginx/demo"
#继续安装
isContinue="Y"
#报错
isError=0
errorMsg=""

##Code

clear
mkdir -p /usr/local/nginx
cd /usr/local/nginx
#查看是否安装
isInstall(){
	if [ `$installPosition/sbin/nginx -v ; echo $?` == "0" ];then
		echo -e "\033[32m 检测到已安装Nginx,是否继续安装? \033[0m    [Y/N]"
		read isContinue;
	else
		clear
		echo "未安装Nginx"
	fi
}

#下载解压Nginx
downloadNginx(){
	if [ ! -f ./${downloadUrl##*/} ];then
		wget $downloadUrl
		if [ "$?" != "0" ];then
			isError=1
			errorMsg="下载Nginx失败"
		fi
	fi
	if [ -d ./$packageName ];then
		clear
		rm -r ./$packageName
	fi
	tar -zxvf ./${downloadUrl##*/} -C ./
	rm -r ./${downloadUrl##*/}
	cd ./$packageName
}

#下载Gcc
downloadGcc()
{
	dpkg -s build-essential
	if [ "$?" != "0" ];then
		apt-get install -y build-essential
		if [ "$?" != "0" ];then
			isError=1
			errorMsg="Gcc安装失败"
		fi
	fi
}

#下载Pcre
downloadPcre(){
	dpkg -s libpcre3
	if [ "$?" != "0" ];then
                apt-get install -y libpcre3
		if [ "$?" != "0" ];then
			isError=1
			errorMsg="Pcre安装失败"
		fi
	fi
	dpkg -s libpcre3-dev
	if [ "$?" != "0" ];then
                apt-get install -y libpcre3-dev
		if [ "$?" != "0" ];then
			isError=1
			errorMsg="Pcre-dev安装失败"
		fi
        fi
}

#下载Zlib
downloadZlib(){
	dpkg -s zlib1g-dev
	if [ "$?" == "0" ];then
                apt-get install -y zlib1g-dev
		if [ "$?" != "0" ];then
			isError=1
			errorMsg="Zlib安装失败"
		fi
        fi
}

#配置安装nginx
installNginx(){
	mkdir -p $installPosition
	./configure --prefix=$installPosition
	make
	if [ "$?" != "0" ];then
		isError=1
		errorMsg="Nginx编译失败"
	else
		make install
		if [ "$?" != "0" ];then
			isError=1
			errorMsg="Nginx安装失败"
		else
			echo -e "-----> \033[32m 安装成功 \033[0m"
		fi
	fi
	
}

isInstall
if [ $isContinue == "Y" ] || [ $isContinue == "y" ];then
	for func in downloadNginx downloadGcc downloadPcre downloadZlib installNginx
	do
		if [ $isError -eq 1 ];then
			echo -e "-----> \033[31m $errorMsg \033[0m"		 
			break
		fi
		$func
	done
fi
