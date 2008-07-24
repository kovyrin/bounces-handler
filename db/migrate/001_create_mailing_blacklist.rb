class CreateMailingBlacklist < ActiveRecord::Migration
  def self.up
    execute <<-EOF
      CREATE TABLE mailing_blacklist (
        id int(10) unsigned NOT NULL auto_increment,
        domain_id int(10) unsigned NOT NULL,
        user_crc32 int(10) unsigned NOT NULL,
        user varchar(100) NOT NULL default '',
        source enum('bounce','unsubscribe','honeypot','other') NOT NULL default 'other',
        level enum('soft','hard') NOT NULL default 'hard',
        reason varchar(50) default NULL,
        created_at timestamp NOT NULL default '0000-00-00 00:00:00' on update CURRENT_TIMESTAMP,
        PRIMARY KEY  (id),
        KEY reports_by_date (domain_id,user_crc32,created_at)
      ) ENGINE=InnoDB
    EOF
  end

  def self.down
    drop_table :mailing_blacklist
  end
end
