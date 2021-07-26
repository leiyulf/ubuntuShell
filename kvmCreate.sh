#!/usr/bin/bash
#Description: KVM Create
#Author: leiyu
#CreateTime: 2021/7/26

##var
isCreateImg=-1
##func
#创建虚拟磁盘
createImg(){
    echo "-------- 创建虚拟磁盘 --------"       
    qemuCommand="qemu-img create"
    imgType=-1
    imgTypeArr=("qcow2" "raw" "qed" "vdi")
    imgPath=""
    imgName=""
    imgCapacity=""
    while [ $imgType != "0" -a $imgType != "1" ]
    do
        echo -en "指定格式 \033[33m(0 : qcow2,1 : raw,2 : qed 3 : vdi)\033[0m : "
        read imgType
    done
    echo -en "创建路径 : "
    read imgPath
    mkdir -p $imgPath
    echo -en "磁盘名称 : "
    read imgName
    echo -en "磁盘大小 : "
    read imgCapacity
    qemuCommand="$qemuCommand -f ${imgTypeArr[$imgType]} $imgPath/$imgName $imgCapacity"
    echo -e "\033[33m$qemuCommand\033[0m"
    $qemuCommand
    if [ $? -ne 0 ];then
        echo -e "\033[31m创建虚拟磁盘失败\033[0m"
    else
        echo -e "\033[32m创建虚拟磁盘成功\033[0m"
    fi
}
#创建虚拟机
createVirt(){
    echo "-------- 创建虚拟机 --------"
    virtCommand="virt-install "
    virtName=""
    virtImg=""
    virtCpu=""
    virtRam=""
    virtIso=""
    #virtOs=""
    echo -en "虚拟机名称 : "
    read virtName
    echo -en "虚拟机磁盘路径 : "
    read virtImg
    echo -en "虚拟机Cpu内核个数 : "
    read virtCpu
    echo -en "虚拟机内存大小(M) : "
    read virtRam
    echo -en "虚拟机镜像路径 : "
    read virtIso
    #echo -en "虚拟机操作系统类型 : "
    #read virtOs
    virtCommand="$virtCommand --name=$virtName --disk path=$virtImg --vcpus=$virtCpu --ram=$virtRam --cdrom=$virtIso --network network=default --graphics vnc,listen=0.0.0.0"
    echo -e "\033[33m$virtCommand\033[0m"
    $virtCommand
    if [ $? -ne 0 ];then
        echo -e "\033[31m创建虚拟机失败\033[0m"
    else
        echo -e "\033[32m创建虚拟机成功\033[0m"
    fi
}

##code
while [ $isCreateImg != "0" -a $isCreateImg != "1" ]
do
    echo -en "是否创建虚拟磁盘 ? \033[33m(1 : 创建,0 : 跳过)\033[0m  "
    read isCreateImg
done

if [ $isCreateImg == "1" ];then
    createImg
fi
createVirt
