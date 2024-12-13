#!/bin/bash
## This file used to fix ecall error in dbUpdateFile.php ##
echo "Start to patch..."
if [ ! "$USER" = "root" ];then
	echo "You MUST have root privileges to execute this patch!"
	exit
fi
patchFile(){
	echo "Start to patch file $1"
	now=`date +%Y%m%d%H%M`
	cp $1{,.$now}
	sed -ri -e 's#\$ecall = \$call \. \"is_ecall=yes\\n\";#\$ecall = \$ecall \. \"is_ecall=yes\\n\";//FIX @'"$now"'#g' -e 's#\$ecall = \$call \. \"is_ecall=no\\n\";#\$ecall = \$ecall \. \"is_ecall=no\\n\";//FIX @'"$now"'#g' $1
	if [ $? -ne 0 ];then
		echo "Patch file failed"
		exit
	fi

	sed -ri 's#\$ecall = \"is_ecall=yes\\n\";#\$ecall = \$ecall \. \"is_ecall=yes\\n\";//FIX @'"$now"'#g' $1
	if [ $? -ne 0 ];then
		echo "Patch file failed"
		exit
	fi
	
}
# Make sure pbxinit location
if [ -f /home/demo/sys-cmd/pbxinit ];then
	pbx_file="/home/demo/sys-cmd/pbxinit"
	echo "Found pbxinit : $pbx_file"
elif [ -f /home/demo/public_html/pbxinit ];then
	pbx_file="/home/demo/public_html/pbxinit"
	echo "Found pbxinit : $pbx_file"
else
	echo "Can not find pbxinit, exit!"
	echo "Failed to patch!"
	exit
fi
# Make sure dbUpdate file location
if [ -f /opt/php/lib/php/dbUpdateFile.php ];then
	file="/opt/php/lib/php/dbUpdateFile.php"
	echo "Found dbUpdateFile : $file"
	patchFile $file
elif [ -f /home/demo/public_html/shared/lib/dbUpdateFile.php ];then
	file="/home/demo/public_html/shared/lib/dbUpdateFile.php"
	echo "Found dbUpdateFile : $file"
	patchFile $file
elif [ -f /home/demo/public_html/dbUpdateFile.php ];then
	file="/home/demo/public_html/dbUpdateFile.php"
	echo "Found dbUpdateFile : $file"
	patchFile $file
else	
	echo "Can not find dbUpdateFile.php, exit!"
	echo "Failed to patch!"
	exit
fi
# Execute dbUpdateFile.php
echo "Execute $file"
php -q $file
if [ ! $? -eq 0 ];then
	echo "Execute dbUpdateFile failed..."
	exit
fi
echo "Success..."
# Execute pbxinit
echo "Execute pbxinit"
sh $pbx_file
if [ ! $? -eq 0 ];then
        echo "Execute pbxinit failed..."
        exit
fi
echo "Success"
# Reload Asterisk
echo "Execute Asterisk reload"
asterisk -rx "core reload"
if [ ! $? -eq 0 ];then
        echo "Execute asterisk reload failed..."
        exit
fi
echo "Done..."
