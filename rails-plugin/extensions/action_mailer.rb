module ActionMailer
  class Base
    alias_method :deliver_without_blacklisting, :deliver!

    def self.filter_blacklisted(level = nil)
      self.send(:include, BouncesHandlerInstanceMethods)
      define_method(:blacklist_level) { level }
    end

    module BouncesHandlerInstanceMethods
      def deliver!(mail = @mail)
        # Cleanup all headers used for recepients specification
        if mail
          [ :to, :cc, :bcc ].each do |header|
            blacklist_cleanup_header(mail, header)
          end
          # Do not send this email if the destination list is empty
          return mail if !mail.destinations || mail.destinations.empty?
        end
        
        deliver_without_blacklisting(mail)
      end

    private
    
      def blacklist_cleanup_header(mail, header_name)
        # Get addrs list from a header
        orig_addrs = mail.send("#{header_name}_addrs".to_sym)
        return unless orig_addrs

        # Clean them up (can't use delete_if for AddressGroups)
        res_addrs = []
        orig_addrs.each do |addr|
          next if MailingBlacklist.banned?(addr.spec, blacklist_level)
          res_addrs << addr
        end
        
        # Assign addrs list back
        mail.send("#{header_name}_addrs=".to_sym, res_addrs)
      end
    
    end    
  end
end
