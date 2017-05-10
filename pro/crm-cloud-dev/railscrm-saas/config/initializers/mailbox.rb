# get credentials from YML file
MAILBOX_CONFIG = YAML.load_file("#{::Rails.root}/config/mailbox.yml")
MAILBOX_CREDENTIALS = MAILBOX_CONFIG[::Rails.env]
#end
