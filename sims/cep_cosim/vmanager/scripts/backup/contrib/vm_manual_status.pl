#!/usr/bin/perl
################################################################################
# Update a vManager Session with Manually Generated Status
################################################################################
use warnings;
use strict;
use Getopt::Long;
use File::Basename;
use File::Path;
use File::Copy;
use Cwd;

# Variables
my $help;
my $debug;
my $session;
my $file_status;

my %attributes;

#===============================================================================
# Process the command line arguments and provide help text
sub help {
  my $prog = basename($0);
  print "This script will update vManager with status information vManager is unaware of, for use in the Dashboard.\n\n";
  print "Usage: $prog [--help] [--debug] --session=<SESSION_NAME> --file_status=<STATUS.TXT>\n";
  print " Options:\n";
  print "\t--help        : Generate this help message.\n";
  print "\t--debug       : Print debug messages during script execution.\n";
  print "\t--session     : vManager session name to update with status.\n";
  print "\t--file_status : The file containing the status information to enter into vManager.\n";
  exit 0;
}

sub usage {
  my $msg = shift || '';
  my $prog = basename($0);
  die("${msg}Use $prog --help for help!\n");
}

GetOptions (
            'help'          => \$help,
            'debug'         => \$debug,
            'session=s'     => \$session,
            'file_status=s' => \$file_status
           ) or usage();

if ($help) {
  help();
}

# Check that requirement Arguments were specified
defined($session)     or usage("Missing argument --session=<SESSION_NAME>\n");
defined($file_status) or usage("Missing argument --file_status=<STATUS.TXT>\n");

# Handle Setting Defaults
# defined($parallel_runs) or $parallel_runs = 1;


######################################################################
# Program Flow
parse_status_file($file_status);
update_session($session);
print "vManager Manual Status Update Complete.\n";
exit 0;


#===============================================================================
sub parse_status_file {
  my $file = $_[0];

  open(STATUS_FILE, "<$file") || die "Failed to open ${file}!";

  while (<STATUS_FILE>) {
    if (/^(\w+)\s*:\s*(\w+)\s*$/) {
      $attributes{$1} = $2;
    } else {
      print "WARNING: Ignoring Line " . $_;
    }
  }
  close(STATUS_FILE);
}

#===============================================================================
sub update_session {
  my $session_name = $_[0];
  my $tcl_file_name;
  my $key;
  my $vm_rc;

  $tcl_file_name = "update_" . $session_name . ".tcl";

  # Create a TCL file to update the status in the session
  open(TCL_FILE, ">$tcl_file_name") || die "Failed to open $tcl_file_name";

  foreach $key (keys(%attributes)) {
    print TCL_FILE "edit " . $session_name . " -attribute " . $key . "=" . $attributes{$key} . "\n";
  }
  print TCL_FILE "\n";
  close(TCL_FILE);

  # Execute the TCL file in vManager
  $vm_rc = system("vmanager -server $ENV{VMGR_SERVER} -exec $tcl_file_name");
  if ($vm_rc != 0) { die "vManager Cleanup Failure - $vm_rc \n"; }
}
