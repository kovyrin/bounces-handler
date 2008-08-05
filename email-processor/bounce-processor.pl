#!/usr/bin/env perl

use strict;
use Cwd;
use File::Basename;

our $SELF_DIR = dirname(Cwd::abs_path(__FILE__));
require $SELF_DIR . '/lib/bounce_db.pm';

use DBI;
use Mail::DeliveryStatus::BounceParser;

#-------------------------------------------------------------------------------

our $mysql_host = 'localhost';
our $mysql_user = 'root';
our $mysql_pass = '';
our $mysql_db = 'bounces';

our $blacklist_table = "mailing_blacklist";
our $domains_table = "mailing_domains";

#-------------------------------------------------------------------------------
# Try to parse the message
my $bounce = eval { 
    Mail::DeliveryStatus::BounceParser->new(\*STDIN);
};

# Fail if can't
if ($@) {
    print "Error: Couldn't parse the message!\n";
    exit(1);
}

# Process the result only if it is a bounce
unless ($bounce->is_bounce) {
    print "OK: This message is not a bounce!\n";
    exit(0)
}

# Connect to mysql to save/update bounces information
my $dbh = DBI->connect("DBI:mysql:database=$mysql_db;host=$mysql_host", $mysql_user, $mysql_pass, {'RaiseError' => 1});

# So, we've got some bounce(s)!
for my $report ($bounce->reports) {
    my $email = $report->get('email');
    my $reason = $report->get('std_reason');
    
    RegisterBounce($email, $reason, $dbh);
}

exit(0);

