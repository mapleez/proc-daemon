#!/bin/bash

#
# Author : ez
# Date : 2017/1/6
# Description : Daemon processes through configuration file.
# 

# configuration file for all daemoned processes.
CONFFILE=proc.conf

# log file.
OUTPUTFILE=logs.log

# pid file of daemon process.
PIDFILE=pid

# second.
INTERVAL=5 

declare -a PROCS
declare PROC_NUM

function parse_procs () {
	while read line; do
		PROCS[$PROC_NUM]="$line"
		PROC_NUM=$[$PROC_NUM+1]
	done < $CONFFILE

	# echo ${PROCS[1]}
	# echo $PROC_NUM
	
	if [ PROC_NUM == 0 ]; then 
		echo "No process to daemon :("
		echo "I'll exit ..."
		exit 0;
	fi
}

function handle_crashed_proc () {
	echo -n "Restart crashed proc $1..."
	if [ !-z $2 && -r $2 ]; then
		. $2
		echo "Done!"
	else
		echo 
		echo "Error restarting proc $1. Ensure executing script $2 is existing and readable. Nothing will be done."
	fi
}

function check_one_proc () {
	proc_name=$1 # ${proc_entry[0]}
	proc_bin=$2  # ${proc_entry[1]}

	echo "[`date`]Starting check $proc_name process...";
	if [ !-z `jps | grep RedisToKafka | cut -d " " -f 2` ]; then
		handle_crashed_proc $proc_name $proc_bin;
	else
		echo "Process $1 is OK!"
	fi
}

# check daemon singleton
if [ -r $PIDFILE ]; then
	PID=`cat $PIDFILE`
	echo "Daemon process has been running at the time with pid $PID, kill it first."
	exit 0;
fi

# parse
parse_procs;

# check_one_proc "${PROCS[0]}";

while (true); do
	for p in ${PROCS[@]}; do
		name=${p[0]}
		bin=${p[1]}
		check_one_proc "$name" "bin";
		echo
	done
	sleep $INTERVAL
done


