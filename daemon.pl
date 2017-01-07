#!/usr/bin/perl

use strict;
use warnings;
use POSIX;

#
# Author : ez
# Date : 2017/1/6
# Description : Daemon processes through configuration file.
# 

# configuration file for all daemoned processes.
my $CONFFILE = "proc.conf";

# log file.
my $STDOUT_FILE = "logs.log";
my $STDERR_FILE = "err.log";

# pid file of daemon process.
my $PIDFILE = "pid";

# second.
my $INTERVAL = 5 ;

my @PROCS = ();
my $PROC_NUM = 0;

#############
# Functions #
#############

sub parse_procs {
	open CONF, $CONFFILE
		or die "Error in openning $CONFFILE: $!\n";

	@PROCS = <CONF>;
	$PROC_NUM = @PROCS;

	if ($PROC_NUM == 0) {
		print "No process to daemon :(\n" .
			"I'll exit ...\n";
		exit 0;
	}

	close CONF;
}

sub daemonlize {
	defined (my $pid = fork) 
		or die "Fork daemon error: $!\n";
	exit 0 if $pid;

	POSIX::setpid ();
	open OUTFD, '>&', $STDOUT_FILE;

	close STDIN;
}

sub handle_crashed_proc {
	my ($proc_name, $proc_bin) = @_;
	print "Restart crashed proc $proc_name...";
	if ($proc_bin ne "" && &check_cmd_existing ($proc_bin)) {
		`$proc_bin`;
		print "Done!\n";
	} else {	
		print "\nError restarting proc $proc_name. Ensure executing script $proc_bin is existing and readable. Nothing will be done.\n";
	}
}

sub check_one_proc {
	my ($proc_name, $proc_bin) = @_;
	chomp (my $time = `date`);

	print "[$time]Starting check $proc_name process...\n";
	if (`jps | grep $proc_name | cut -d " " -f 2` eq "") {
		&handle_crashed_proc ($proc_name, $proc_bin);
	} else {
		print "Process $proc_name is OK!\n";
	}
}


sub check_cmd_existing {
 my ($env, $cmd) = ($ENV {'PATH'}, shift);
 my @path = split /:/, $env;
 foreach my $p (@path) {
 	if ( -r $p ) {
 		my @res = grep /^$cmd$/, `ls $p`;
 		return 1 if (@res);
	}
 }
 0;
}


###################
# Main process.   #
###################

# check daemon singleton
if ( -r $PIDFILE ) {
	my $PID = `cat $PIDFILE`;
	print "Daemon process has been running at the time with pid $PID, kill it first.\n";
	exit 0;
}

# parse
&parse_procs;
&daemonlize;

while (1) {
	foreach my $p (@PROCS) {
		chomp $p;
		my ($name, $bin) = split " ", $p;
		&check_one_proc ($name, $bin);
	}
	sleep $INTERVAL;
	print "\n";
}

__END__

