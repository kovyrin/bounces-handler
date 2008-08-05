#-------------------------------------------------------------------------------
sub RegisterBounce($$$) {
    my ($email, $reason, $dbh) = @_;
    print "BOUNCE: $email with reason $reason\n";
    
    my ($email_user, $email_domain) = split(/\@/, lc($email));
    unless ($email_user && $email_domain) {
        print "Invalid email address!\n";
        exit(1);
    }
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

1;