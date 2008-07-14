class Blacklist < ActiveRecord::Base
  establish_connection configurations[RAILS_ENV]['bounces_handler']
  set_table_name 'mailing_blacklist'
  
  def self.banned?(email, level = nil)
    parsed_email = parse_email(email)
    
    domain = MailingDomain.find_by_name_crc(parsed_email[:domain])
    return false unless domain
    
    conditions = {}
    conditions[:domain_id] = domain.id
    conditions[:user] = parsed_email[:user]
    conditions[:user_crc32] = Zlib.crc32(parsed_email[:user])
    count(conditions) > 0
  end
  
  def self.hard_banned?(email)
    banned?(email, :hard)
  end

  def self.soft_banned?(email)
    banned?(email, :soft)
  end
  
  
end
