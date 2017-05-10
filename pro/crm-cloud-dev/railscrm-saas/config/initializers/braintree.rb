BT_CONFIG = YAML.load_file("#{::Rails.root}/config/braintree.yml")
BT_CREDENTIALS = BT_CONFIG[::Rails.env]

Braintree::Configuration.environment = BT_CREDENTIALS['environment']
Braintree::Configuration.merchant_id = BT_CREDENTIALS['merchant_id']
Braintree::Configuration.public_key = BT_CREDENTIALS['public_key']
Braintree::Configuration.private_key = BT_CREDENTIALS['private_key']

