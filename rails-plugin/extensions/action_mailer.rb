module ActionMailer
  class Base
    alias_method :deliver_without_blacklisting, :deliver!

    def self.filter_blacklisted(level = nil)
      self.send(:include, BouncesHandlerInstanceMethods)
      define_method(:blacklist_level) { level }
    end

    module BouncesHandlerInstanceMethods
      def deliver!(mail = @mail)
        if mail
          [ :to, :cc, :bcc ].each do |header|
            blacklist_cleanup_header(mail, header)
          end
          return mail if mail.destinations.empty?
        end
        
        deliver_without_blacklisting(mail)
      end

    private
    
      def blacklist_cleanup_header(mail, header_name)
        # Get addrs list from a header
        orig_addrs = mail.send("#{header_name}_addrs".to_sym)

        # Clean them up
        res_addrs = orig_addrs.delete_if do |addr|
          MailingBlacklist.banned?(addr.spec, blacklist_level)
        end
        
        # Assign addrs list back
        mail.send("#{header_name}_addrs=".to_sym, res_addrs)
      end
    
    end    
  end
end
