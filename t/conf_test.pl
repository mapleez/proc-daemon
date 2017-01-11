#!/usr/bin/perl

use strict;
use warnings;
use Config::Tiny;

use lib "..";


my $config_hdl = Config::Tiny -> new;

$config_hdl = Config::Tiny -> read ("../conf/daemon.conf");

print "version = ", $$config_hdl {_} {version}, "\n";
print "stdout_file = ", $$config_hdl {_} {stdout_file}, "\n";

__END__

