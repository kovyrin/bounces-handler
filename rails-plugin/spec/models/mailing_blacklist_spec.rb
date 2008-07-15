require File.dirname(__FILE__) + '/../spec_helper'

describe MailingBlacklist, "ban-detecting features" do
  fixtures :mailing_domains, :mailing_blacklist

  it "should have test1@yahoo.com soft and hard banned" do
    MailingBlacklist.hard_banned?('test1@yahoo.com').should be_true
    MailingBlacklist.soft_banned?('test1@yahoo.com').should be_true
  end

  it "should have test2@yahoo.com soft banned only" do
    MailingBlacklist.hard_banned?('test2@yahoo.com').should be_false
    MailingBlacklist.soft_banned?('test2@yahoo.com').should be_true
  end

  it "should have test1@yahoo.com and test2@yahoo.com both banned" do
    MailingBlacklist.banned?('test1@yahoo.com').should be_true
    MailingBlacklist.banned?('test2@yahoo.com').should be_true
  end

  it "should not have test@yahoo.com banned" do
    MailingBlacklist.banned?('test@yahoo.com').should be_false
  end

  it "should not have test@yahoo.ca banned" do
    MailingBlacklist.banned?('test@yahoo.ca').should be_false
  end
  
  it "should be able to find all black listings for an address" do
    MailingBlacklist.listings_for_email('test1@yahoo.com').should have(1).item
    MailingBlacklist.listings_for_email('test2@yahoo.com').should have(1).item
  end
end

describe MailingBlacklist, "banning/unbanning features" do
 fixtures :mailing_domains, :mailing_blacklist

 it "should successfully unban an address" do
   MailingBlacklist.banned?('test1@yahoo.com').should be_true
   MailingBlacklist.unban!('test1@yahoo.com')
   MailingBlacklist.banned?('test1@yahoo.com').should be_false
 end

 it "should successfully ban an address" do
   MailingBlacklist.banned?('test@yahoo.com').should be_false
   MailingBlacklist.ban!('test@yahoo.com', :hard, 'test reason').should be_valid
   MailingBlacklist.banned?('test@yahoo.com').should be_true
 end

 it "should successfully ban an address with an unknown domain" do
   MailingBlacklist.banned?('test@yahoo.ca').should be_false
   MailingBlacklist.ban!('test@yahoo.ca', :hard, 'test reason').should be_valid
   MailingBlacklist.banned?('test@yahoo.ca').should be_true
 end
end
