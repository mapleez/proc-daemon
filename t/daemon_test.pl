#!/usr/bin/perl

use strict;
use warnings;

sub find_proc {
	my $proc_name = shift;
	!! scalar `ps -e | grep $proc_name`;
}

my $proc_name = "daemonsrv";

while (1) {
	print "$$\n";
	# if (&find_proc ($proc_name)) {
	# 	print $proc_name, " => ok\n";
	# } else {
	# 	print $proc_name, " => err\n";
	# }
	sleep (1);
}

__END__

