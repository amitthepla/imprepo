#
require 'base64'
require 'faraday'
require 'google/api_client'
#
module GmailClient
  class Gmail
    attr_accessor :access_token

    def initialize(access_token, email)
      @access_token = access_token
      @client = Google::APIClient.new({application_name: 'TheConversionDoctor', application_version: '1.0'})
      @client.authorization.access_token = @access_token
      @service = @client.discovered_api('gmail')
      @email = email
    end

    def fetch_labels
      begin
        result = @client.execute(
            :api_method => @service.users.labels.list,
            :parameters => {'userId' => 'me'},
            :headers => {'Content-Type' => 'application/json'}
        )
        JSON.parse(result.body)['labels']
      rescue => ex
        p ex.message
      end
    end

    def fetch_label_by_id(label_id)
      begin
        result = @client.execute(
            :api_method => @service.users.labels.get,
            :parameters => {'userId' => 'me', id: label_id},
            :headers => {'Content-Type' => 'application/json'}
        )
        JSON.parse(result.body)
      rescue => ex
        p ex.message
      end
    end

    def fetch_emails_by_label(label_id, options = {})
      begin
        emails = []
        result = @client.execute(
            :api_method => @service.users.messages.list,
            :parameters => {userId: 'me', labelIds: label_id}.merge(options),
            :headers => {'Content-Type' => 'application/json'}
        )

        parsed_result = JSON.parse(result.body)
        messages = parsed_result['messages'] || []
        messages.each do |msg|
          emails << get_details(msg['id'])
        end
      rescue => ex
        p ex.message
      end
      return emails, parsed_result['nextPageToken'].to_s
    end

    def search_emails(options = {})
      begin
        emails = []
        result = @client.execute(
            :api_method => @service.users.messages.list,
            :parameters => {userId: 'me'}.merge(options),
            :headers => {'Content-Type' => 'application/json'}
        )
        parsed_result = JSON.parse(result.body)
        messages = parsed_result['messages'] || []
        messages.each do |msg|
          emails << get_details(msg['id'])
        end
      rescue => ex
        p ex.message
      end
      return emails, parsed_result['nextPageToken'].to_s
    end

    def get_details(msg_id)
      begin
        result = @client.execute(
            :api_method => @service.users.messages.get,
            :parameters => {userId: 'me', id: msg_id, format: 'full'},
            :headers => {'Content-Type' => 'application/json'}
        )
        JSON.parse(result.body)
      rescue => ex
        p ex.message
        {}
      end
    end

    def get_attachment(msg_id, attachment_id)
      begin
        result = @client.execute(
            :api_method => @service.users.messages.attachments.get,
            :parameters => {userId: 'me', messageId: msg_id, id: attachment_id},
            :headers => {'Content-Type' => 'application/json'}
        )
        JSON.parse(result.body)['data']
      rescue => ex
        p ex.message
        ''
      end
    end

    def toggle_star(msg_id, starred = true)
      begin
        payload = starred ? {'removeLabelIds' => ['STARRED']} : {'addLabelIds' => ['STARRED']}
        result = @client.execute(
            :api_method => @service.users.messages.modify,
            :parameters => {userId: 'me', id: msg_id},
            :headers => {'Content-Type' => 'application/json'},
            :body => payload.to_json
        )
        result.success?
      rescue => ex
        p ex.message
        false
      end
    end

    def toggle_unread(msg_ids, unread = true)
      begin
        payload = unread ? {'addLabelIds' => ['UNREAD']} : {'removeLabelIds' => ['UNREAD']}
        msg_ids.split(',').each do |id|
          @client.execute({
                              :api_method => @service.users.messages.modify,
                              :parameters => {userId: 'me', id: id},
                              :headers => {'Content-Type' => 'application/json'},
                              :body => payload.to_json
                          })
        end
      rescue => ex
        p ex.message
        false
      end
    end

    def delete_emails(msg_ids)
      begin
        payload = {ids: msg_ids.split(',')}
        result = @client.execute(
            :api_method => @service.users.messages.batch_delete,
            :parameters => {userId: 'me'},
            :headers => {'Content-Type' => 'application/json'},
            :body => payload.to_json
        )
        result.success?
      rescue => ex
        p ex.message
        false
      end
    end

    def send_mail(options)
      begin
        email = build_mail(options)
        result = @client.execute(
            :api_method => @service.users.messages.discovered_methods.select { |m| m.name == 'send' }.first,
            :parameters => {userId: 'me'},
            :headers => {'Content-Type' => 'application/json'},
            :body => {raw: Base64.urlsafe_encode64(email.to_s)}.to_json
        )
        JSON.parse(result.body)
      rescue => ex
        p ex.message
        false
      end
    end

    def build_mail(options)
      begin
        email = Mail.new        
        email.to = options[:to]
        email.cc = options[:cc]
        email.subject = options[:subject]
        if options[:is_reply_message] == "true"
          email.in_reply_to = options[:reply_to_message_id]
        else
          email.from = @email
          email.date = Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')
        end

        html_part = Mail::Part.new do
          content_type('text/html; charset=UTF-8')
          body(options[:body].gsub("\n", ''))
        end

        email.html_part = html_part
        (options['files'] || []).each do |file|
          email.attachments[file.original_filename] = {:mime_type => file.content_type, :content => file.read}
          # email.add_file({filename: file.original_filename, content: file.read})
        end
        email
      rescue
        nil
      end
    end
  end
end
#### Outlook ####
module OutlookClient
  class Outlook
    attr_accessor :access_token, :email

    def initialize(access_token, email)
      @access_token = access_token
      @email = email
      @conn = Faraday.new(:url => 'https://outlook.office.com') do |faraday|
        # Outputs to the console
        faraday.response :logger
        # faraday.response :logger
        # Uses the default Net::HTTP adapter
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end

    def get_outlook_details(msg_id)
      begin
        response = @conn.get do |request|
          # Get messages from the inbox
          # Sort by ReceivedDateTime in descending orderby
          # Get the first 20 results
          request.url "/api/v2.0/Me/messages/#{msg_id}?"

          request.headers['Authorization'] = "Bearer #{@access_token}"
          request.headers['Accept'] = 'application/json'
          request.headers['X-AnchorMailbox'] = @email
        end
        JSON.parse(response.body)
      rescue => ex
        p ex.message
        {}
      end
    end

    def fetch_labels
      begin
        response = @conn.get do |request|
          request.url "/api/v2.0/me/MailFolders"
          request.headers['Authorization'] = "Bearer #{@access_token}"
          request.headers['Accept'] = 'application/json'
          request.headers['X-AnchorMailbox'] = @email
        end
        JSON.parse(response.body)['value']
      rescue => ex
        p ex.message
      end
    end


    def fetch_emails_by_label(label_id, options = {})
      begin
        response = @conn.get do |request|
          # Get messages from the inbox
          # Sort by ReceivedDateTime in descending orderby
          # Get the first 20 results
          request.url "/api/v2.0/Me/MailFolders/#{label_id}/messages?$orderby=ReceivedDateTime desc&$select=ReceivedDateTime,Subject,From,ToRecipients,HasAttachments,IsRead,BodyPreview&$top=#{ENV['EMAILS_PER_PAGE'] || 20}&$skip=#{options[:pageToken]}"

          request.headers['Authorization'] = "Bearer #{@access_token}"
          request.headers['Accept'] = 'application/json'
          request.headers['X-AnchorMailbox'] = @email
        end
        parsed_result = JSON.parse(response.body)
        return parsed_result['value'], parsed_result['@odata.nextLink']
      rescue => ex
        p ex.message
        []
      end
    end

    def fetch_label_by_id(label_id)
      begin
        response = @conn.get do |request|
          # Get messages from the inbox
          # Sort by ReceivedDateTime in descending orderby
          # Get the first 20 results
          request.url "/api/v2.0/Me/MailFolders/#{label_id}"

          request.headers['Authorization'] = "Bearer #{@access_token}"
          request.headers['Accept'] = 'application/json'
          request.headers['X-AnchorMailbox'] = @email
        end

        # Assign the resulting value to the @messages
        # variable to make it available to the view template.
        JSON.parse(response.body)
      rescue => ex
        p ex.message
      end
    end

    def toggle_unread(msg_ids, unread = true)
      begin
        payload = unread ? false : true
        msg_ids.split(',').each do |id|
          response = @conn.patch do |request|
            # Get messages to update
            request.url "/api/v2.0/me/messages/#{id}"
            request.headers['Authorization'] = "Bearer #{@access_token}"
            request.options.params_encoder = Faraday::FlatParamsEncoder
            request.headers['Content-Type'] = 'application/json'
            request.headers['X-AnchorMailbox'] = @email
            p request.body = "{'IsRead': #{payload}}"
          end
        end
      rescue => ex
        p ex.message
        false
      end
    end

    def delete_emails(msg_ids)
      begin
        payload = {ids: msg_ids.split(',')}
        msg_ids.split(',').each do |id|
          response = @conn.delete do |request|
            # Get Message URL
            request.url "/api/v2.0/me/messages/#{id}"
            request.headers['Authorization'] = "Bearer #{@access_token}"
            request.options.params_encoder = Faraday::FlatParamsEncoder
            request.headers['Content-Type'] = 'application/json'
            request.headers['X-AnchorMailbox'] = @email
          end
        end
      rescue => ex
        p ex.message
        false
      end
    end

    def send_outlook_mail(options)
      begin
        response = @conn.post do |request|
          request.url '/api/v2.0/me/sendmail'

          request.headers['Authorization'] = "Bearer #{@access_token}"
          request.options.params_encoder = Faraday::FlatParamsEncoder
          request.headers['Content-Type'] = 'application/json'
          request.headers['X-AnchorMailbox'] = @email
          request.body = compose_mail(options).to_json
        end
        JSON.parse(response.body)
      rescue => ex
        false
      end
    end

    def compose_mail(options)
      if options['files'].present?
        bytes = ''
        file_name = ''
        (options['files'] || []).each do |file|
          file_name= file.original_filename
          file_data = File.open(file.tempfile.path, 'rb') { |io| io.read }
          bytes = Base64.encode64(file_data).gsub("\n", '')
        end
        {
            Message: {
                Subject: options[:subject],
                Body: {
                    ContentType: 'Text',
                    Content: ActionView::Base.full_sanitizer.sanitize(options[:body]).gsub(/&nbsp;/i, ' ')
                },
                ToRecipients: [
                    {
                        EmailAddress: {
                            Address: options[:to]
                        }
                    }
                ],
                Attachments: [
                    {
                        "@odata.type": '#Microsoft.OutlookServices.FileAttachment',
                        Name: file_name,
                        ContentBytes: bytes
                    }
                ]
            },
            SaveToSentItems: 'true'
        }
      else
        {
            Message: {
                Subject: options[:subject],
                Body: {
                    ContentType: 'Text',
                    Content: ActionView::Base.full_sanitizer.sanitize(options[:body]).gsub(/&nbsp;/i, ' ')
                },
                ToRecipients: [
                    {
                        EmailAddress: {
                            Address: options[:to]
                        }
                    }
                ]
            },
            SaveToSentItems: 'true'
        }
      end
    end
  end
end