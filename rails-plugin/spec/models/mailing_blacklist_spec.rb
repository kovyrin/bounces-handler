require File.dirname(__FILE__) + '/../spec_helper'

describe MailingBlacklist do
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

end