#!/usr/bin/env perl

use strict;

use DBI;
use Mail::DeliveryStatus::BounceParser;

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

# So, we've got some bounce(s)!
for my $report ($bounce->reports) {
    my $email = $report->get('email');
    my $reason = $report->get('std_reason');
    
    print "BOUNCE: $email with reason $reason\n";
}
