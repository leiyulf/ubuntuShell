#!/usr/bin/bash
#Author : leiyu
#Description : memory
#createDate : 2021-7-16


drawSlider(){
	count=$1
	usedNum=$2
	echo -n "["
	for(( i = 0;i < $count;i++ ))
	do
		if [ $(( $count * 2 )) -lt 30 ];then
			echo -en "\033[32m=\033[0m"
		elif [ $(( $count * 2 )) -lt 70 ] && [ $(( $count * 2 )) -ge 30 ];then
			echo -en "\033[33m=\033[0m"
		else
			echo -en "\033[31m=\033[0m"
		fi
	done
	for(( i = 0;i < 50 - $count;i++ ))
	do
		echo -n "="
	done
	echo -en "]  $usedNum % \n"
}

while [ 0 ]
do
	clear
	echo "当前内存使用率 : "
	mem1=`head -2 /proc/meminfo | awk ' NR == 1 { m1 = $2 } NR == 2 { m2 = $2 ; print ( m1 - m2 ) / m1 * 100 } '`
	count=$((`echo $mem1 | awk -F "." ' { print $1 } '` / 2))
	
	drawSlider $count $mem1
	echo
	echo "-------------------"
	echo
	echo "当前磁盘使用率 : "
	disk1=`df | awk ' $6 == "/"  { print $3 / $2 * 100 } '`
	count2=$((`echo $disk1 | awk -F "." ' { print $1 } '` / 2))	
	drawSlider $count2 $disk1
	sleep 1
done


