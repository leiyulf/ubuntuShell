for ((;;))
do
	ping -c1 $1 > /var/null
	if [ $? == "0" ];then
		echo -e "`date +"%F %H:%M:%S"` - $1 : \033[32m ok \033[0m"
	else
		echo -e "`date +"%F %H:%M:%S"` - $1 : \033[31m no \033[0m"
	fi
	sleep 1;
done
