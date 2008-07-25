require File.dirname(__FILE__) + '/../spec_helper'

class MyMailer < ActionMailer::Base 
  def my_email(input_headers)
    input_headers.each do |h, v|
      headers[h.to_s] = v
    end
  end
end

describe MyMailer, "with filter_blacklisted()" do
  fixtures :mailing_domains, :mailing_blacklist

  it "should filter out all blocked addresses" do
    MyMailer.filter_blacklisted

    mail = MyMailer.deliver_my_email(
      :to => 'test1@yahoo.com, test1_ok@yahoo.com',
      :cc => 'test2@yahoo.com, test2_ok@yahoo.com',
      :bcc => 'test3@yahoo.com, test3_ok@yahoo.com'
    )

    mail.destinations.should_not include('test1@yahoo.com', 'test2@yahoo.com', 'test3@yahoo.com')
    mail.destinations.should include('test1_ok@yahoo.com', 'test2_ok@yahoo.com', 'test3_ok@yahoo.com')
  end
end

describe MyMailer, "with filter_blacklisted(:soft)" do
  fixtures :mailing_domains, :mailing_blacklist

  it "should filter out all soft- and hard-blocked addresses" do
    MyMailer.filter_blacklisted(:soft)

    mail = MyMailer.deliver_my_email(
      :to => 'test1@yahoo.com, test1_ok@yahoo.com',
      :cc => 'test2@yahoo.com, test2_ok@yahoo.com',
      :bcc => 'test3@yahoo.com, test3_ok@yahoo.com'
    )

    mail.destinations.should_not include('test1@yahoo.com', 'test2@yahoo.com', 'test3@yahoo.com')
    mail.destinations.should include('test1_ok@yahoo.com', 'test2_ok@yahoo.com', 'test3_ok@yahoo.com')
  end
end

describe MyMailer, "with filter_blacklisted(:hard)" do
  fixtures :mailing_domains, :mailing_blacklist
  
  before(:each) do
    MyMailer.filter_blacklisted(:hard)
  end
  
  it "should filter out all hard-blocked addresses" do
    mail = MyMailer.deliver_my_email(
      :to => 'test1@yahoo.com, test1_ok@yahoo.com',
      :cc => 'test2@yahoo.com, test2_ok@yahoo.com',
      :bcc => 'test3@yahoo.com, test3_ok@yahoo.com'
    )

    mail.destinations.should_not include('test1@yahoo.com')
    mail.destinations.should include('test1_ok@yahoo.com', 'test2_ok@yahoo.com', 'test3_ok@yahoo.com', 'test2@yahoo.com', 'test3@yahoo.com')
  end
  
  [ :to, :cc, :bcc ].each do |header|
    it "should be able to perform filtering with empty #{header} mail header" do
      params = {
        :to => 'test1@yahoo.com, test1_ok@yahoo.com',
        :cc => 'test2@yahoo.com, test2_ok@yahoo.com',
        :bcc => 'test3@yahoo.com, test3_ok@yahoo.com'
      }
      params.delete(header)
      lambda { MyMailer.deliver_my_email(params) }.should_not raise_error
    end
  end
end
