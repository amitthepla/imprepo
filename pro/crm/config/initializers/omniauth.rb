#config/initalizers/omniauth.rb
#
# Outlook Details
OUTLOOK_CLIENT_ID = ENV['OUTLOOK_CLIENT_ID'].freeze
OUTLOOK_CLIENT_SECRET = ENV['OUTLOOK_CLIENT_SECRET'].freeze
OUTLOOK_SCOPES = %w(openid offline_access https://outlook.office.com/mail.readwrite https://outlook.office.com/mail.send).freeze
OUTLOOK_REDIRECT_URI = ENV['OUTLOOK_REDIRECT_URL'].freeze
#
# Outlook OAuth Builder
OUTLOOK_CLIENT = OAuth2::Client.new(OUTLOOK_CLIENT_ID,
                                    OUTLOOK_CLIENT_SECRET,
                                    :site => 'https://login.microsoftonline.com',
                                    :authorize_url => '/common/oauth2/v2.0/authorize',
                                    :token_url => '/common/oauth2/v2.0/token')
#
# Google Details
# GOOGLE_CLIENT_ID = ENV['GOOGLE_CLIENT_ID'].freeze
# GOOGLE_CLIENT_SECRET = ENV['GOOGLE_CLIENT_SECRET'].freeze
#
# Google Details
GOOGLE_NOTES_CLIENT_ID = ENV['GOOGLE_NOTES_CLIENT_ID'].freeze
GOOGLE_NOTES_CLIENT_SECRET = ENV['GOOGLE_NOTES_CLIENT_SECRET'].freeze

GOOGLE_CLIENT_ID = "1056470742173-9isq6l6cgku2vqbmr15krqorgufiv63j.apps.googleusercontent.com"
GOOGLE_CLIENT_SECRET = "Xz02sSLe055gitdAMAKW_9xh"

#
# Google OAuth Builder
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, {
      scope: %w(https://mail.google.com/ plus.me userinfo.email),
      access_type: 'offline',
      prompt: 'consent',
      name: 'google'
  }
end
#
# Google OAuth Notes Builder
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, GOOGLE_NOTES_CLIENT_ID, GOOGLE_NOTES_CLIENT_SECRET, {
      scope: %w(https://mail.google.com/ plus.me userinfo.email),
      access_type: 'offline',
      prompt: 'consent',
      name: 'notes',
      callback_path: '/auth/google/notes/callback'
  }
end
