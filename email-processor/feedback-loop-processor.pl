#!/usr/bin/env perl

use strict;
use Cwd;
use File::Basename;
use DBI;
use Data::Dumper;
use Email::MIME;

our $SELF_DIR = dirname(Cwd::abs_path(__FILE__));
require $SELF_DIR . '/lib/bounce_db.pm';

#-------------------------------------------------------------------------------

our $mysql_host = 'localhost';
our $mysql_user = 'root';
our $mysql_pass = '';
our $mysql_db = 'bounces';

our $blacklist_table = "mailing_blacklist";
our $domains_table = "mailing_domains";

#-------------------------------------------------------------------------------
# Read the report from stdin
my $report_text = '';
while(<>) {
    $report_text .= $_;
}

# Try to parse the report
my $report = eval {
    Email::MIME->new($report_text);
};

if ($report) {
    # Process the report
    my $report_email = ProcessReport($report);
    HandleFeedback($report_email) if ($report_email);
    
    $report_email = ProcessUnknownReport($report);
    HandleFeedback($report_email) if ($report_email);
}

#FIXME: forward the message to a human for review

exit(0);

#-------------------------------------------------------------------------------
sub ProcessReport($) {
    my $report = shift;

    my $from = $report->header('From');
    
    return ProcessHotmailReport($report) if ($from eq 'staff@hotmail.com');
    return ProcessUnknownReport($report) if ($from eq 'scomp@aol.net');

    print "Warning: Unknown report source!\n";
    return undef;
}

#-------------------------------------------------------------------------------
sub ProcessHotmailReport($) {
    my $report = shift;
    
    my @parts = $report->parts;
    for my $part (@parts) {
        my $part_email = eval { Email::MIME->new($part->body_raw); };
        next unless ($part_email);
        return $part_email->header('To');
    }
    
    print "ERROR: Can't parse hotmail report!\n";
    return undef;
}

#-------------------------------------------------------------------------------
sub ProcessUnknownReport($) {
    my $report = shift;

    my $from = $report->header('From');
    my $to = $report->header('To');

    # Here you can do your own processing stuff
    # The code below is for scribd.com
    
    my $body = $report->body_raw;
    if ($body =~ /http:\/\/www.scribd.com\/optout\/\w+\/(.*\@.*)/) {
        return $1;
    }
    
    print "ERROR: Can't parse unknown report from '$from' to '$to')!\n";
    return undef;
}

#-------------------------------------------------------------------------------
sub HandleFeedback($) {
    my $email = shift;
    
    print("Blacklisting email: $email\n");
    
    # Connect to mysql to save blacklist information
    my $dbh = DBI->connect("DBI:mysql:database=$mysql_db;host=$mysql_host", $mysql_user, $mysql_pass, {'RaiseError' => 1});
    
    # Register the record
    RegisterBounce($email, 'feedback-loop', $dbh, 'soft');
    
    exit(0)
}
