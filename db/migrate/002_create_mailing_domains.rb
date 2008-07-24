class CreateMailingDomains < ActiveRecord::Migration
  def self.up
    execute <<-EOF
      CREATE TABLE mailing_domains (
        id int(10) unsigned NOT NULL auto_increment,
        name_crc32 int(10) unsigned NOT NULL default '0',
        name varchar(100) NOT NULL default '',
        PRIMARY KEY  (id),
        UNIQUE KEY name_crc32 (name_crc32, name)
      ) ENGINE=InnoDB
    EOF
  end

  def self.down
    drop_table :mailing_domains
  end
end
