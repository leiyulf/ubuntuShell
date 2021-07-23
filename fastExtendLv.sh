#!/usr/bin/bash
#Author : leiyu
#Description : fast extend lv
#createDate : 2021-7-23

##var
diskName=""  #选择的磁盘
msgBef=""    #分区之前的磁盘列表
msgAft=""    #分区之后的磁盘列表
diffStr=""   #新增分区名
pvName=""    #物理卷名
vgName=""    #卷组名
lvName=""    #逻辑卷名
freeBlock="" #空闲的块
isError=1    #是否出错
##func

# 从不同的地方开始截取
#$1 - 更变前的字符串
#$2 - 更变后的字符串
#$3 - 截取长度
cutStr(){
    beforeStr=$1
    afterStr=$2
    len=$3

    for i in `seq 1 1 ${#afterStr}`
    do
        if [[ ${beforeStr:$i-1:1} != ${afterStr:$i-1:1} ]];then
           diffStr="$diffStr${afterStr:$i-1:1}"
           if [ ${#diffStr} -eq $len ];then
                isError=0
                break
           fi
        fi
    done
}

#扩展lv卷
extendLv(){
    echo -e "\033[33m输入分区名 :\033[0m"
    read pvName
    echo -e "\033[33m输入卷组名 :\033[0m"
    read vgName
    echo -e "\033[33m输入逻辑卷名 :\033[0m"
    read lvName

    pvcreate /dev/$pvName
    vgextend $vgName /dev/$pvName

    freeBlock=`vgdisplay | awk ' $1 == "Free" { print $5 } '`
    lvextend -l +$freeBlock /dev/$vgName/$lvName

    if [ $? != "0" ];then
        echo -e "\033[31m扩展失败\033[0m"
    else
        echo -e "\033[32m扩展成功\033[0m"
    fi

    resize2fs /dev/$vgName/$lvName
}

##code
clear
echo -e "\033[33m磁盘使用情况:\033[0m"
msgBef=`lsblk | awk ' $1 !~ "loop" { print $0  } '`
lsblk | awk ' $1 !~ "loop" { print $0  } '
echo -en "\033[33m选择磁盘对逻辑卷进行扩容 : \033[0m"
read diskName
#创建分区
fdisk /dev/$diskName << EOF
    n
    p



    t
    8e
    w
EOF

clear
msgAft=`lsblk | awk ' $1 !~ "loop" { print $0  } '`
#截取改变过的分区
cutStr `echo $msgBef | sed "s/ /_/g"` `echo $msgAft | sed "s/ /_/g"` 7 

if [ $isError -eq 0 ];then
    #_转空格
    diffStr=`echo $diffStr | sed "s/_/ /g" `

    echo -e "\033[33m新建的分区  ↓\033[0m"
    lsblk | awk ' $0 ~ diffStr { print "\033[32m" $0 "\033[0m" } ' diffStr=$diffStr

    echo "--------------------"
    extendLv
else
    echo -e "\033[31m磁盘分区失败\033[0m"
fi