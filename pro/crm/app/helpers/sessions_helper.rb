module SessionsHelper
  def handle_google_response(data, user)
    begin
      credentials = data['credentials']
      e_account = EmailAccount.new({
                                       provider: data['provider'],
                                       email: data['info']['email'],
                                       access_token: credentials['token'],
                                       refresh_token: credentials['refresh_token'],
                                       expires: credentials['expires'],
                                       expires_at: credentials['expires_at']
                                   })
      e_account.user = user
      e_account.save!
    rescue => ex
      p ex.message
      false
    end
  end

  def handle_lead_notes_response(data, organization)
    begin
      credentials = data['credentials']
      e_account = Business::EmailAccount.new({
                                                 email: data['info']['email'],
                                                 access_token: credentials['token'],
                                                 refresh_token: credentials['refresh_token'],
                                                 expires: credentials['expires'],
                                                 expires_at: credentials['expires_at']
                                             })
      e_account.organization = organization
      e_account.save!
    rescue => ex
      p ex.message
      false
    end
  end

  module Outlook
    extend self

    def handle_outlook_response(outlook_data, user)
      begin
        user_email = get_user_email(outlook_data.token)
        e_account = EmailAccount.new({
                                         provider: 'outlook',
                                         email: user_email,
                                         access_token: outlook_data.token,
                                         refresh_token: outlook_data.refresh_token,
                                         expires: outlook_data.expires_at.present?,
                                         expires_in: outlook_data.expires_in,
                                         expires_at: outlook_data.expires_at
                                     })
        e_account.user = user
        e_account.save!
      rescue => ex
        p ex.message
        false
      end
    end

    # Exchanges an authorization code for a token
    def get_token_from_code(auth_code)
      OUTLOOK_CLIENT.auth_code.get_token(auth_code,
                                         :redirect_uri => OUTLOOK_REDIRECT_URI,
                                         :scope => OUTLOOK_SCOPES.join(' '))
    end

    def get_user_email(access_token)
      conn = Faraday.new(:url => 'https://outlook.office.com') do |faraday|
        # Outputs to the console
        faraday.response :logger
        # Uses the default Net::HTTP adapter
        faraday.adapter Faraday.default_adapter
      end
      response = conn.get do |request|
        # Get user's info from /Me
        request.url 'api/v2.0/Me'
        request.headers['Authorization'] = "Bearer #{access_token}"
        request.headers['Accept'] = 'application/json'
      end
      JSON.parse(response.body)['EmailAddress']
    end
  end
end
