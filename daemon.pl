#!/usr/bin/perl

#############################################################
# Author : ez
# Date : 2017/1/6
# Description : Daemon processes through configuration file.
############################################################# 

use strict;
use warnings;

use Config::Tiny;
use POSIX();

####################
# Configuration    #
####################

my $conf_hdl = Config::Tiny -> new;
$conf_hdl = Config::Tiny -> read ("conf/daemon.conf");

# Release version at 2017-1-7
$::VERSION = $$conf_hdl {_} {version};

# configuration file for all daemoned processes.
my $CONFFILE = $$conf_hdl {_} {proc_conf};

# log file.
my $STDOUT_FILE = $$conf_hdl {_} {stdout_file};
my $STDERR_FILE = $$conf_hdl {_} {stderr_file};

# pid file of daemon process.
my $PIDFILE = $$conf_hdl {_} {pid_file};

# interval seconds
my $INTERVAL = $$conf_hdl {_} {interval};

my $PWD = ".";

my @PROCS = ();
my $PROC_NUM = 0;

#############
# Functions #
#############

# parse configuration.
sub parse_procs {
	open CONF, $CONFFILE
		or die "Error in openning $CONFFILE: $!\n";

	while (<CONF>) {
		push @PROCS, $_
			unless ($_ =~ /^(#+|\s+)/)
	}
	$PROC_NUM = @PROCS;

	if ($PROC_NUM == 0) {
		print "No process to daemon :(\n" .
			"I'll exit ...\n";
		exit 0;
	}

	close CONF;
}

# daemonize this process.
sub daemonize {
	# Fork a child.
	defined (my $pid = fork) 
		or die "Fork daemon error: $!\n";
	
	# Exit parent process.
	exit 0 if $pid; 

	# Detach the child from the terminal 
	# (No controlling tty). make it the 
	# session-leader and the process-group-leader
	# of a new process group.
	die "Cannot detach from controlling terminal: $!\n"
		if &POSIX::setsid () < 0;

	# chdir to $PWD.
	die "Can't chdir to $PWD: $!\n" unless chdir $PWD;

	# Redirect stdout and stderr.
	open STDOUT, '+>', $STDOUT_FILE;
	if ($STDOUT_FILE eq $STDERR_FILE) {
		open STDERR, '>&', STDOUT;
	} else {
		open STDERR, '+>', $STDERR_FILE;
	}
}

sub check_daemon_proc_file {
	if ( -r $PIDFILE ) {
		my $PID = `cat $PIDFILE`;
		print "Daemon process has been running at the time with pid $PID, kill it first.\n";
		exit 0;
	}
}

sub handle_crashed_proc {
	my ($proc_name, $proc_bin) = @_;
	print "Restart crashed proc $proc_name...";
	if ($proc_bin ne "" && &check_cmd_existing ($proc_bin)) {
		# Note: We just reboot service process.
		`$proc_bin`;
		print "Done!\n";
	} else {	
		print "\nError restarting proc $proc_name. Ensure executing script $proc_bin is existing and readable. Nothing will be done.\n";
	}
}

sub find_proc {
	my $proc_name = shift;
	!! scalar `ps -e | grep $proc_name`;
}

sub check_one_proc {
	my ($proc_name, $proc_bin) = @_;
	chomp (my $time = `date`);

	print "[$time]Starting check $proc_name process...\n";
	unless (`jps | grep $proc_name | cut -d " " -f 2` ne "" || 
			&find_proc ($proc_name)) {
		unless (defined $proc_bin) {
			print "Restart executing script is empty!!!\n";
			return;
		}
		&handle_crashed_proc ($proc_name, $proc_bin);
	} else {
		print "Process $proc_name is OK!\n";
	}
}

sub check_cmd_existing {
 my ($env, $cmd) = ($ENV {'PATH'}, shift);
 return 1 if ( -r $cmd );
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

# check
# &check_daemon_proc_file;

# &daemonize;

# parse
&parse_procs;

print "@PROCS", ", $PROC_NUM\n";


# Start loop
# while (1) {
# 	foreach my $p (@PROCS) {
# 		chomp $p;
# 		my ($name, $bin) = split " ", $p;
# 		&check_one_proc ($name, $bin);
# 	}
# 	sleep $INTERVAL;
# 	print "\n";
# }

__END__

=head1 daemonize

Make the process to be a daemon process.

=head1 handle_crashed_proc

If a process being daemoned is crashed, we restart it.

=over 2

=item 1

Process name being parsed by config file.

=item 2

Process boot script for restarting operation.

=back

=head1 check_one_proc

Check a process is running or not at the time.

=over 2

=item 1

Process name being parsed by config file.

=item 2

Process boot script for restarting operation.

=back

=head1 check_cmd_existing

Check the OS environment and find the command is existing for booting process.

=over

=item 1

Shell command to restart process while crashed.

=back

