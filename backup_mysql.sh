#!/bin/bash
#@author:puxu
#
backupdir="/root/backup"
dbuser="root"
dbpassword=""
db_defaults_file="/etc/my.cnf"
full_backup_dir="$backupdir/fullback"
insert_backup_dir="$backupdir/insert_back"
weekday=`date +%w`
insert_back_num=$1                       #增量备份几天一次
now=`date +'%Y-%m-%d %H:%M:%S'`
logdir="$backupdir/log"

if [ ! -d $full_backup_dir ]; then
	mkdir -p $full_backup_dir
fi

if [ ! -d $insert_backup_dir ]; then
	mkdir -p $insert_backup_dir
fi

if [ ! -d $logdir ]; then
	mkdir -p $logdir
fi

function full_back()
{
	innobackupex --defaults-file=$db_defaults_file --user=$dbuser --password=$dbpassword $full_backup_dir |gzip  > /root/mysql_backup/`date +%Y-%m-%d_%H-%M-%S`.tar.gz
	if [ $? -eq 0 ];then
		echo "$now --Backup--Info-- Fullbackup completed OK!"
		return 0
	else
		echo "$now --Backup--Error-- Fullbackup  is Fail: innobackupex  commond run error!"
		return 2
	fi
}


function insert_back()
{
	count=`ls $full_backup_dir|wc -l`
	if [ $count -eq 0 ]; then
		full_back
		if [ $? -ne 2 ];then
			full_last_filename=$(find $full_backup_dir -name "`date +%Y-%m-%d*`" -print|awk -F / '{print $NF}')
			echo "$now --Backup--Info-- Base dir: $full_backup_dir/$full_last_filename, Insertbackup is running !"
			innobackupex --defaults-file=$db_defaults_file --user=$dbuser --password=$dbpassword --incremental-basedir=$full_backup_dir/$full_last_filename --incremental $insert_backup_dir
			if [ $? -eq 0 ];then
				echo "$now --Backup--Info-- Insertbackup completed OK!"
			else
				echo "$now --Backup--Error-- InsertBackup  is Fail: innobackupex  commond run error!"
			fi
		else 
			return 0
		fi
	else
		timestamp_now=`date +%s`
		timestamp_back=`expr $timestamp_now - 3600 \* 24 \* $insert_back_num`
		strftime_back=`date -d @$timestamp_back  "+%Y-%m-%d"`
		insert_last_filename=$(find $insert_backup_dir -name "$strftime_back*" -print|awk -F / '{print $NF}')
		insert_count=$(find $insert_backup_dir -name "$strftime_back*" -print|awk -F / '{print $NF}' | wc -l)
		if [ $insert_count -ne 0 ];then
			echo "$now --Backup--Info-- Base dir: $insert_backup_dir/$insert_last_filename, Insertbackup is running !"
			innobackupex --defaults-file=$db_defaults_file --user=$dbuser --password=$dbpassword --incremental-basedir=$insert_backup_dir/$insert_last_filename --incremental $insert_backup_dir
			if [ $? -eq 0 ];then
				echo "$now --Backup--Info-- Insertbackup completed OK!"
			else
				echo "$now --Backup--Error-- InsertBackup  is Fail: innobackupex  commond run error!"
			fi
		else
			echo "$now --Backup--Error-- InsertBackup  is Fail: Last $insert_back_num day insert file do not exist!"
			return 0
		fi
	fi
}


function main()
{
	if [ $weekday -eq 6 ];then
		full_back
	elif [ $weekday -eq 7 ]; then
		timestamp_now=`date +%s`
		timestamp_back=`expr $timestamp_now - 3600 \* 24 \* 1`
		strftime_back=`date -d @$timestamp_back  "+%Y-%m-%d"`
		full_last_filename=$(find $full_backup_dir -name "$strftime_back*" -print|awk -F / '{print $NF}')
		full_count=$(find $full_backup_dir -name "$strftime_back*" -print|awk -F / '{print $NF}' | wc -l)
		if [ $full_count -ne 0 ];then
			echo "$now --Backup--Info-- Base dir: $full_backup_dir/$full_last_filename, Insertbackup is running !"
			innobackupex --defaults-file=$db_defaults_file --user=$dbuser --password=$dbpassword --incremental-basedir=$full_backup_dir/$full_last_filename --incremental $insert_backup_dir
			if [ $? -eq 0 ];then
				echo "$now --Backup--Info-- Insertbackup completed OK!"
			else
				echo "$now --Backup--Error-- InsertBackup  is Fail: innobackupex  commond run error!"
			fi
		else
			echo "$now --Backup--Error-- InsertBackup  is Fail: Last $insert_back_num day fullback file do not exist!"
			return 0
		fi
	else
		insert_back
	fi
}

main "$@" >> $logdir/backup_mysql_`date +%Y%m%d`.log
