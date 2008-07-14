class Blacklist < ActiveRecord::Base
  establish_connection configurations[RAILS_ENV]['bounces_handler']
  set_table_name 'mailing_blacklist'
end
