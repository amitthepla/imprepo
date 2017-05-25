module GmailHelper
  class EmailFetcher
    attr_accessor :gmail

    def initialize(username, password)
      begin
        raise 'Please provide username and password.' if username.blank? && password.blank?
        @gmail = Gmail.connect!(username, password)
      rescue Exception => ex
        p ex.message
      end
    end

    def unread_emails
      @gmail.inbox.find(:unread, :after => Date.today)
    end

    def all_unread_emails
      @gmail.inbox.find(:unread)
    end

    def from_address(email)
      "#{email.from[0].mailbox}@#{email.from[0].host}"
    end

    def to_address(email)
      "#{email.to[0].mailbox}@#{email.to[0].host}"
    end

    def logout
      @gmail.logout
    end

    def parse_body(email)
      host = email.sender[0].host
      case (host.split('.').first)
        when 'yahoo'
          yahoo_body = email.html_part.body.decoded
          doc = Nokogiri::HTML(yahoo_body)
          doc.at_xpath("//div[@class='yahoo_quoted']").remove if doc.at_xpath("//div[@class='yahoo_quoted']")
          Nokogiri::HTML(yahoo_body).xpath('//body').to_s
        when 'outlook'
          outlook_body = email.html_part.body.decoded
          doc = Nokogiri::HTML(outlook_body)
          doc.at_xpath("//div[@dir='ltr']/font").remove if doc.at_xpath("//div[@dir='ltr']/font")
          doc.at_xpath("//div[@dir='ltr']/div").remove if doc.at_xpath("//div[@dir='ltr']/div")
          doc.at_xpath("//div[@dir='ltr']").to_s
        else
          google_body = email.html_part.body.decoded
          doc = Nokogiri::HTML(google_body)
          doc.at_xpath("//div[@class='gmail_signature']").remove if doc.at_xpath("//div[@class='gmail_signature']")
          doc.at_xpath("//div[@dir='ltr']")
      end
    end

    def parse_realself_body(email)
      body = email.html_part.body.decoded
      Nokogiri::HTML(body)
    end

  end
end
