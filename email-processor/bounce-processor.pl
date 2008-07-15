#!/usr/bin/env perl

use strict;

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

#-------------------------------------------------------------------------------
sub RegisterBounce($$$) {
    my ($email, $reason, $dbh) = @_;
    print "BOUNCE: $email with reason $reason\n";
    
    my ($email_user, $email_domain) = split(/\@/, lc($email));
    my $domain_id = RegisterBounceDomain($email_domain, $dbh);
    
    my $level = ($reason eq 'over_quota') ? 'soft' : 'hard';
    RegisterBounceEmail($email_user, $domain_id, $reason, $level, $dbh);
}

#-------------------------------------------------------------------------------
sub RegisterBounceDomain($$) {
    my ($domain, $dbh) = @_;
    
    # Lookup domain name
    my $sth = $dbh->prepare("SELECT id FROM $domains_table WHERE name = ? AND name_crc32 = CRC32(?)");
    $sth->execute($domain, $domain);
    my $row = $sth->fetchrow_hashref;
    return $row->{id} if $row;

    # If not found, create it
    print "Registering domain: $domain\n";
    $sth = $dbh->prepare("INSERT INTO $domains_table SET name = ?, name_crc32 = CRC32(?)");
    $sth->execute($domain, $domain);
    return $dbh->{'mysql_insertid'};
}

#-------------------------------------------------------------------------------
sub RegisterBounceEmail($$$$$) {
    my ($email_user, $domain_id, $reason, $level, $dbh) = @_;
    
    my $sql = "
        INSERT INTO $blacklist_table SET
          domain_id = ?,
          user_crc32 = CRC32(?),
          user = ?,
          source = 'bounce',
          level = ?,
          reason = ?,
          created_at = NOW()
    ";
    my $sth = $dbh->prepare($sql);
    $sth->execute($domain_id, $email_user, $email_user, $level, $reason);
}
