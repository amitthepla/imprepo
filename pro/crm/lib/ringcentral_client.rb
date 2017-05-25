require 'ringcentral_sdk'

# Returns RingCentralSdk::Platform instance
module RingCentralClient
	class RingCentral
		def initialize
			@client = RingCentralSdk.new(
			  # '3Y1TiMO9SaeSpjqA-3QwNg',
			  # 'cZA_mdptToSFEdaxF19XtwGamtuCBFR7GPRurvdQNfLA',
			  'dJoZgNFoRYSWg45lXjGc_A',
			  'Vm5IY68MTzK3KVNtZxtk7AAy7pXEe3Q9q3IsAeqg403g',
			  RingCentralSdk::RC_SERVER_SANDBOX,
			  redirect_uri: 'http://localhost:3001/dashboard'
			)
		end

		def authorize_url
			return @client.authorize_url()
			#return client.authorize 'my_username', 'my_extension', 'my_password'
		end

		def authorize_code(code)
			return @client.authorize_code(code)
		end
	end
# extension will default to company admin extension if not provided
#client.authorize_password('myUsername', '305.860.0717', 'Miami2310!')
end