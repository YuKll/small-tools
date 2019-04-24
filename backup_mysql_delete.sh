#!/bin/bash
#@author:puxu

backupdir="/root/backup"
logdir="$backupdir/log"
now=`date +'%Y-%m-%d %H:%M:%S'`
full_backup_dir="$backupdir/fullback"
insert_backup_dir="$backupdir/insert_back"

if [ ! -d $logdir ]; then
	mkdir -p $logdir
fi

function rm_backup()
{
	timestamp_now=`date +%s`
	rm_num=$1
	timestamp_rm=`expr $timestamp_now - 3600 \* 24 \* $rm_num`
	strftime_rm=`date -d @$timestamp_rm  "+%Y-%m-%d"`
	ls $full_backup_dir | grep "$strftime_rm" > /dev/null

	if [ $? -eq 0 ]; then
		filename=$full_backup_dir/$strftime_rm*
		echo "$now --delete--info-- $filename will rm..."
		rm -rf $full_backup_dir/$strftime_rm*
		if [ $? -eq 0 ]; then
			echo "$now --Delete--Info-- rm successful!"
		else
			echo "$now --Delete--Error-- rm fail!"
		fi
	else
		echo  "$now --Delete--Info-- $strftime_rm 日期无 full backup 文件！"
	fi

	ls $insert_backup_dir | grep "$strftime_rm" > /dev/null

	if [ $? -eq 0 ]; then
		insert_filename=$insert_backup_dir/$strftime_rm*
		echo "$now --Delete--Info-- $insert_filename will rm..."
		rm -rf $insert_backup_dir/$strftime_rm*
		if [ $? -eq 0 ]; then
			echo "$now --Delete--Info-- rm successful!"
		else
			echo "$now --Delete--Error-- rm fail!"
		fi
	else
		echo  "$now --Delete--Info-- $strftime_rm 日期无 insert backup 文件！"
	fi
}


function main()
{
	rm_backup $1
}


main "$@" >> $logdir/delete_mysql_`date +%Y%m%d`.log