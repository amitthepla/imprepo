require 'base64'
require 'uri'
require 'net/http'
module Business::EmailHelper
  def get_email_content(email)
    payload = email['payload']
    email_body =
        begin
          case payload['mimeType']
            when 'text/html', 'text/plain'
              fetch_from_html(payload)
            when 'multipart/alternative'
              fetch_from_alternative(payload)
            when 'multipart/mixed'
              fetch_from_mixed(payload)
            when 'multipart/related'
              fetch_from_related(payload, email['id'])
            else
              "<strong class='text-danger'>Could not recognize the email content.</strong>"
          end
        rescue => ex
          p ex.message
          "<strong class='text-danger'>Unable to parse email body.</strong>"
        end
    email_body.force_encoding('UTF-8').html_safe
  end

  def generate_forward_content(content, basic_info)
    str = ''
    str += '---------- Forwarded message ----------<br/>'
    str += 'From: '+ (basic_info[:from].split('<').first.strip) +'<br/>'
    str += 'Subject: '+  basic_info[:subject] +'<br/>'
    str += 'To: '+ (basic_info[:to].split('<').first.strip) +'<br/><br/><br/>'
    str += content
    str.html_safe
  end

  def generate_reply_content(content, basic_info)
    #str = '<br/><br/>------'
    str = ''
    str += '<blockquote><br/>'
    str += content
    str += '</blockquote>'
    str.html_safe
  end


  def fetch_from_related(payload, id)
    parts = payload['parts'].select { |part| part['mimeType'] == 'multipart/alternative' }[0]['parts']
    html_part = parts.select { |part| part['mimeType'] == 'text/html' }[0]
    encoded_body = html_part['body']['data']

    attachment_parts = payload['parts'].select { |part| part['mimeType'] != 'multipart/alternative' }

    attachments = []
    attachment_parts.each do |part|
      attachment_id = part['body']['attachmentId']
      attachment = Base64.urlsafe_decode64(@api_client.get_attachment(id, attachment_id))
      attachments << "<img src='data:#{part['mimeType']};base64,#{Base64.encode64(attachment)}'/>"
    end
    Base64.urlsafe_decode64(encoded_body).gsub('\n', '').gsub('\r', '').gsub('\\', '') + '<br>' + attachments.join('')
  end

  def fetch_from_mixed(payload)
    parts = payload['parts'].select { |part| part['mimeType'] == 'multipart/alternative' }[0]
    parts = parts.present? ? parts['parts'] : payload['parts']
    html_part = parts.select { |part| part['mimeType'] == 'text/html' }[0]
    encoded_body = html_part['body']['data']
    Base64.urlsafe_decode64(encoded_body).gsub('\n', '').gsub('\r', '').gsub('\\', '')
  end

  def fetch_from_alternative(payload)
    parts = payload['parts']
    html_part = parts.select { |part| part['mimeType'] == 'text/html' }[0]
    encoded_body = html_part['body']['data']
    Base64.urlsafe_decode64(encoded_body).gsub('\n', '').gsub('\r', '').gsub('\\', '')
  end

  def fetch_from_html(payload)
    encoded_body = payload['body']['data']
    Base64.urlsafe_decode64(encoded_body).gsub('\n', '').gsub('\r', '').gsub('\\', '')
  end

  def get_header_attribute(gmail_data, attribute)
    begin
      headers = gmail_data['payload']['headers']
      array = headers.reject { |hash| hash['name'] != attribute }
      array.first.present? ? array.first['value'] : ''
    rescue
      ''
    end
  end

  def get_email_communicators(email)
    data = {
        from: get_header_attribute(email, 'From').match(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i).to_s,
        to: get_header_attribute(email, 'To').match(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i).to_s,
        received: get_header_attribute(email, 'Received').split(';').pop.strip.to_datetime.to_i
    }
    p data
    return data
  end

  def get_basic_info(email)
    {
        subject: get_header_attribute(email, 'Subject'),
        from: get_header_attribute(email, 'From'),
        to: get_header_attribute(email, 'To'),
        received: get_header_attribute(email, 'Received').split(';').pop.strip.to_datetime.to_i,
        snippet: email['snippet'],
        attachment: get_header_attribute(email, 'X-MS-Has-Attach').present?,
        unread: email['labelIds'].include?('UNREAD'),
        starred: email['labelIds'].include?('STARRED'),
        id: email['id'],
        msg_id: get_header_attribute(email, 'Message-ID').present? ? get_header_attribute(email, 'Message-ID') : get_header_attribute(email, 'Message-Id'),
        in_reply_to: get_header_attribute(email, 'Reply-to').present? ? get_header_attribute(email, 'Reply-to') : get_header_attribute(email, 'From'),
        cc: get_header_attribute(email, 'Cc')
    }
  end

  module Outlook
    extend self

    def get_outlook_url
      OUTLOOK_CLIENT.auth_code.authorize_url(:redirect_uri => OUTLOOK_REDIRECT_URI, :scope => OUTLOOK_SCOPES.join(' '))
    end

    def get_outlook_info(email)
      {
          subject: email['Subject'],
          from: (email['From']['EmailAddress']['Name'] rescue ''),
          to: (email['ToRecipients'][0]['EmailAddress']['Name'] rescue ''),
          received: email['ReceivedDateTime'].to_datetime.to_i,
          snippet: email['BodyPreview'],
          attachment: email['HasAttachments'],
          unread: !email['IsRead'],
          starred: email['Flag'],
          id: email['Id']
      }
    end

    def get_outlook_email_content(email)
      payload = email['Body']
      email_body =
          begin
            case payload['ContentType']
              when 'HTML'
                # Do Something
                fetch_outlook_from_html(payload)
              else
                "<strong class='text-danger'>Could not recognize the email content.</strong>"
            end
          rescue => ex
            p ex.message
            "<strong class='text-danger'>Unable to parse email body.</strong>"
          end
      email_body.force_encoding('UTF-8').html_safe
    end

    def fetch_outlook_from_html(payload)
      payload['Content']
    end
  end
end
