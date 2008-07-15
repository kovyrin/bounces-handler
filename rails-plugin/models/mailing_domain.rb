require 'zlib'

class MailingDomain < ActiveRecord::Base
  establish_connection configurations[RAILS_ENV]['bounces_handler']
  before_validation :fill_name_crc32_field

  def fill_name_crc32_field
    self['name_crc32'] = Zlib.crc32(self['name'])
  end
  
  def self.find_by_name_crc(name)
    find(:first, :conditions => { :name => name, :name_crc32 => Zlib.crc32(name)})
  end
end
