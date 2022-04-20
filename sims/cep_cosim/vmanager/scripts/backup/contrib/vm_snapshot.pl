#!/usr/bin/perl
################################################################################
# This script will take a runVmanager output file, parse out the session
# name, and then modify the session name and session owner and then
# perform a vManager tracking snapshot.
################################################################################
use warnings;
use strict;
use Getopt::Long;
use File::Basename;
use File::Path;
use File::Copy;
use Cwd;
use POSIX qw(ceil);

# Variables
my $help;
my $debug;
my $log;
my $owner;
my $cfg;
my $block;
my $status_file;
my $date_string;
my $jira_component;

my $session_name;
my $session_out;
my $sha;
my $vm_rc;
my $attr_file;
my $snapshot_file;
my $python_path;

#===============================================================================
# Process the command line arguments and provide help text
sub help {
  my $prog = basename($0);
  print "This script will rename a vMangager session and perform a vManager tracking snapshot.\n\n";
  print "Usage: $prog [--help] [--debug] --log=<FILE> --owner=<userid> [--date_string==<YYYY_MM_DD>]\n";
  print "\t--block=<Block Name> --cfg=<Tracking Config Name> [--status_file=<MANUAL STATUS>]\n";
  print "\t[--jira_comp=<Jira Component Name>]\n";
  print " Options:\n";
  print "\t--help        : Generate this help message.\n";
  print "\t--debug       : Print debug messages during script execution.\n";
  print "\t--log         : runVmanager log file\n";
  print "\t--owner       : The owner to assign to the vManager session having a snapshot taken.\n";
  print "\t--block       : The block name\n";
  print "\t--cfg         : Tracking configuration to send the snapshot to.\n";
  print "\t--status_file : Manual status to enter into vManager.\n";
  print "\t--date_string : Date string to use in session name, if omitted current date is used.\n";
  print "\t--jira_comp   : Jira component name, if specified will dump Jira Bug metrics into the session for tracking.\n";
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
            'log=s'         => \$log,
            'owner=s'       => \$owner,
            'block=s'       => \$block,
            'cfg=s'         => \$cfg,
            'status_file=s' => \$status_file,
            'date_string=s' => \$date_string,
            'jira_comp=s'   => \$jira_component
           ) or usage();

if ($help) {
  help();
}

# Check that requirement Arguments were specified
defined($log)   or usage("Missing argument --log=<FILE>\n");
defined($owner) or usage("Missing argument --owner=<userid>\n");
defined($block) or usage("Missing argument --block=<Block Name>\n");
defined($cfg)   or usage("Missing argument --cfg=<Tracking Config Name>\n");

# Handle Setting Defaults
# defined($parallel_runs) or $parallel_runs = 1;

# Print Debug Information before starting
#if ($debug) {
  print "vManager Session Log File     = " . $log . "\n";
  print "vManager Session Output Owner = " . $owner . "\n";
  print "vManager Tracking Config Name = " . $cfg . "\n";
#}

######################################################################
# Program Flow

# Grab the date
if (not defined($date_string)) {
  $date_string = get_date_string();
}
$session_out = "REGR_" . $block . "_" . $date_string;

# Grab the GIT SHA
#$sha = get_sha();

# Get the session name...
$session_name = parse_log_for_session_name($log);

# Create a TCL file to run in vManager:
$attr_file = $session_name . "_attr.tcl";
open(TCL_FILE, ">$attr_file") || die "Failed to open ${attr_file}!";

# - Modify session attributes - name, comment
print TCL_FILE "edit " . $session_name . " -attribute session_name=" . $session_out . "\n";
#print TCL_FILE "edit " . $session_out  . " -attribute comment=" . $sha . "\n";
print TCL_FILE "edit " . $session_out  . " -attribute regr_block_name=" . $block . "\n";

close(TCL_FILE);

# Excute the TCL File in vManager.
$vm_rc = system("vmanager -server $ENV{VMGR_SERVER} -exec $attr_file");
if ($vm_rc != 0) { die "vManager Attribute Change Failure - $vm_rc \n"; }

# Update the Dashboard Attributes, extract coverage information and put it into attributes in the session view
$python_path = get_python_path();
#$vm_rc = system("$python_path $ENV{RF_TOP}/tools/contrib/vm_dashboard_update.py $session_out $cfg $ENV{VMGR_SERVER}");
#$vm_rc = system("$python_path $VM_DASHBOARD/contrib/vm_dashboard_update.py $session_out $cfg $VMGR_SERVER");
$vm_rc = system("$python_path $ENV{VM_DASHBOARD}/contrib/vm_dashboard_update.py $session_out $cfg $ENV{VMGR_SERVER}");
if ($vm_rc != 0) { die "vManager Dashboard Update Failure - $vm_rc \n"; }

# Update the session with manual status, if the status file exists
if (defined($status_file)) {
#  $vm_rc = system("$VM_DASHBOARD/contrib/vm_manual_status.pl -s $session_out -f $status_file");
  $vm_rc = system("$ENV{VM_DASHBOARD}/contrib/vm_manual_status.pl -s $session_out -f $status_file");
  if ($vm_rc != 0) { die "vManager Manual Status Update Failure - $vm_rc \n"; }
}

# Update the session with Jira bug status, if the option requested it.
if (defined($jira_component)) {
  $vm_rc = system("vm_jira_capture.pl -s $session_out -c '" . $jira_component . "'");
  if ($vm_rc != 0) { die "vManager Jira Status Update Failure - $vm_rc \n"; }
}

# Take the snapshot as the very last step, this will allow all the attributes we just entered to be captured in the snapshot.
# - Create a TCL file to run in vManager:
$snapshot_file = $session_name . "_snapshot.tcl";
open(TCL_FILE, ">$snapshot_file") || die "Failed to open ${snapshot_file}!";

# - Load the session
print TCL_FILE "load -session " . $session_out . "\n";

# - Snapshot the session
print TCL_FILE "snapshot -config " . $cfg . " -context -title " . $date_string . "\n";

# - Switch the owner after the snapshot has been taken
print TCL_FILE "edit " . $session_out  . " -attribute owner=" . $owner . "\n";

close(TCL_FILE);

# Excute the TCL File in vManager.
$vm_rc = system("vmanager -server $ENV{VMGR_SERVER} -exec $snapshot_file");
if ($vm_rc != 0) { die "vManager Snapshot Failure - $vm_rc \n"; }

# Snapshot Complete
print "vManager Session Snapshot Complete.\n";

exit 0;


#===============================================================================
sub parse_log_for_session_name {
  my $log_file = $_[0];
  my $session_name;

  open(LOG_FILE, "<$log_file") || die "Failed to open ${log_file}!";

  while (<LOG_FILE>) {
    if (/^Session\s+(\S+)\s+status\s+is/) {
      $session_name = $1;
      close(LOG_FILE);
      if ($debug) { print "Session name is " . $session_name . "\n"; }
      return $session_name;
    }
  }

  close(LOG_FILE);
  die "Bad log file format, couldn't find the session name in the runVmanager output!\n";
}

#===============================================================================
sub get_sha {
  my $cmd = "git log --pretty=format:'%H' -n 1";
  my $line;

  open(GSTAT, "-|", $cmd) or die "Can't run '$cmd' : $!";

  while (<GSTAT>) {
    $line = $_;
    chomp($line);
  }
  close(GSTAT);

  if ($debug) { print "GIT SHA = " . $line . "\n"; }

  return $line;
}

#===============================================================================
# Get the Python path from the MDV release.  MDV Versions 18.04 and earlier
# used Python 2.7.9, and did not link Python into MDV/tools/bin.  MDV versions
# 18.05 and later are using Python 3.5.5 and are linking it into MDV/tools/bin.
sub get_python_path {
  my $cmd = "vm_root";
  my $result_line;
  my $pp;  # Python Path

  open(VM_ROOT, "-|", $cmd) or die "Can't run '$cmd' : $!";

  while (<VM_ROOT>) {
    $result_line = $_;
    chomp($result_line);
  }
  close(VM_ROOT);

  if (-e "${result_line}/tools/bin/python") {
    $pp = "${result_line}/tools/bin/python";
  } else {
    $pp = "${result_line}/tools/python372/bin/python3.7";
  }

  return $pp;
}

#===============================================================================
sub get_date_string {
  my $year;
  my $month;
  my $day;
  my $hour;
  my $minute;
  my $second;

  ($second, $minute, $hour, $day, $month, $year) = localtime(time);

  # Perform Conversion to get it into a good format for naming
  $year = $year + 1900;
  $month = $month + 1;
  if ($month < 10)  { $month = "0" . $month; }
  if ($day < 10)    { $day = "0" . $day; }

  return ($year . "_" . $month . "_" . $day);
}
