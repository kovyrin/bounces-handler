class MailingBlacklist < ActiveRecord::Base
  establish_connection configurations[RAILS_ENV]['bounces_handler'] if configurations[RAILS_ENV]['bounces_handler']
  set_table_name 'mailing_blacklist'
  belongs_to :mailing_domain, :foreign_key => :domain_id

  def self.listings_for_email(email, level = nil)
    # Reject invalid emails
    return [] unless valid_email?(email)

    parsed_email = parse_email(email)
    
    domain = MailingDomain.find_by_name_crc(parsed_email[:domain])
    return [] unless domain
    
    conditions = {}
    conditions[:domain_id] = domain.id
    conditions[:user] = parsed_email[:user]
    conditions[:user_crc32] = Zlib.crc32(parsed_email[:user])
    conditions[:level] = level.to_s if level
    find(:all, :conditions => conditions)
  end

  def self.banned?(email, level = nil)
    # Reject invalid emails
    return true unless valid_email?(email)

    parsed_email = parse_email(email)

    # Check if domain exists in the system
    domain = MailingDomain.find_by_name_crc(parsed_email[:domain])
    return false unless domain
    
    # Find blacklisting records
    conditions = {}
    conditions[:domain_id] = domain.id
    conditions[:user] = parsed_email[:user]
    conditions[:user_crc32] = Zlib.crc32(parsed_email[:user])
    conditions[:level] = level.to_s if level && level != :soft # soft = hard + soft = all (no need for filter)
    count(:conditions => conditions) > 0
  end
  
  def self.hard_banned?(email)
    # Hard banned = banned with :hard level
    banned?(email, :hard)
  end

  def self.soft_banned?(email)
    # Soft banned = banned with :soft or :hard level
    banned?(email)
  end

  def self.unban!(email)
    # Reject invalid emails
    return unless valid_email?(email)

    parsed_email = parse_email(email)
    
    domain = MailingDomain.find_by_name_crc(parsed_email[:domain])
    return false unless domain

    conditions = {}
    conditions[:domain_id] = domain.id
    conditions[:user] = parsed_email[:user]
    conditions[:user_crc32] = Zlib.crc32(parsed_email[:user])
    delete_all(conditions)
  end
  
  def self.ban!(email, level, reason, source = :other)
    # Reject invalid emails
    return unless valid_email?(email)

    parsed_email = parse_email(email)
    
    domain = MailingDomain.find_by_name_crc(parsed_email[:domain]) || MailingDomain.create(:name => parsed_email[:domain])
    
    opts = {}
    opts[:domain_id] = domain.id
    opts[:user] = parsed_email[:user]
    opts[:user_crc32] = Zlib.crc32(parsed_email[:user])
    opts[:reason] = reason.to_s

    raise "Invalid level. Should be :hard or :soft!" unless [:hard, :soft].include?(level)
    opts[:level] = level.to_s

    raise "Invalid source. Should be :bounce, :unsibscribe, :honeypot or :other!" unless [:bounce, :unsibscribe, :honeypot, :other].include?(source)
    opts[:source] = source.to_s

    create(opts)
  end
  
private

  def self.parse_email(email)
    user, domain = email.to_s.downcase.split(/@/)
    { :user => user, :domain => domain }
  end

  def self.valid_email?(email)
    return false unless email && email.size < 50
    !! email.match(/^((?:(?:(?:[a-zA-Z0-9][\.\-\+_]?)*)[a-zA-Z0-9])+)\@((?:(?:(?:[a-zA-Z0-9][\.\-_]?){0,62})[a-zA-Z0-9])+)\.([a-zA-Z0-9]{2,6})$/)
  end
end
