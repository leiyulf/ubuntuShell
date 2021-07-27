#!/usr/bin/bash
#Author : leiyu
#Description : localApt (Nginx)
#createDate : 2021-7-27

##var
nginxConfPath="/usr/local/nginx/demo/conf"  #nginx配置文件路径
debPath="/var/cache/apt/archives"           #debs包路径
webPath="/var/debs"                         #搭建的本地源路径
webPort=8080                                #端口
error=0                     
errorMsg=""

##func
#检查错误
checkErr(){       
    if [ $1 != "0" -a $1 -ne 0 ];then
        error=1
        errorMsg=$2
    else
        echo -e "\033[32m$3\033[0m"
    fi
}

#检查nginx
checkNginx(){
    nginx -v
    checkErr $? "未安装Nginx" "已安装Nginx....."
}

#拷贝deb包作为本地源
cpDebs(){
    mkdir -p $webPath/ubuntu/software/
    mkdir -p $webPath/var/debs/ubuntu/dists/focal/main/binary-i386/
    mkdir -p $webPath/var/debs/ubuntu/dists/focal/main/binary-amd64/
    debCount=`ls -l $debPath/*.deb | awk ' END { print NR } '`
    echo -e "\033[32m开始拷贝debs.....\033[0m"
    echo -e "共发现 \033[33m$debCount\033[0m 个文件"
    cp $debPath/*.deb $webPath/ubuntu/software/
    checkErr $? "检查包路径是否正确" "拷贝debs成功....."
}

#创建索引
mkPackages(){
    dpkg-scanpackages $webPath/ubuntu/software/ /dev/null | gzip > $webPath/var/debs/ubuntu/dists/focal/main/binary-i386/Packages.gz
    dpkg-scanpackages $webPath/ubuntu/software/ /dev/null | gzip > $webPath/var/debs/ubuntu/dists/focal/main/binary-amd64/Packages.gz
    checkErr $? "创建索引文件失败" "创建索引文件成功"
}

#配置nginx.conf
configNginx(){
    cd $nginxConfPath
    if [ ! -f ./nginx.conf ];then
        checkErr 0 "未找到配置文件,请检查路径"
    else
        cp ./nginx.conf ./nginx.conf.cp
        echo -e "\033[32mnginx.conf已备份\033[0m"
        cat nginx.conf | awk ' $0 !~ "#" && NF != 0 { print $0 > "./nginx.conf" } '
        sed -i "/listen/c\        listen $webPort;" ./nginx.conf
        sed -i '0,/root/{//d}' ./nginx.conf
        sed -i '0,/index.html/{//d}' ./nginx.conf
        sed -i "/location \//a\            root $webPath;" ./nginx.conf
        sed -i '/location \//a\            autoindex on;' ./nginx.conf
        echo -e "\033[32mnginx.conf修改完成 (若再次运行此脚本的话,将配置文件恢复默认)\033[0m"
    fi
}

#启动服务
startService(){
    cd $nginxConfPath
    if [ `lsof -i :$webPort | awk ' END { print NF } '` == "0" ];then
        ../sbin/nginx
    else
        kill -9 `lsof -i :$webPort | awk ' NR > 1 { print $2 } '`
        ../sbin/nginx
    fi
    checkErr $? "nginx服务启动失败" "nginx服务启动成功"
}

##code

#checkNginx
#cpDebs
#mkPackages
#configNginx
#startService

for func in checkNginx cpDebs mkPackages configNginx startService
do
    if [ $error -eq 1 ];then
		echo -e "-----> \033[31m $errorMsg \033[0m"		 
		break
	fi
	$func
done