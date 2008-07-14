class MailingDomain < ActiveRecord::Base
  establish_connection configurations[RAILS_ENV]['bounces_handler']
  belongs_to :mailing_blacklist
end
