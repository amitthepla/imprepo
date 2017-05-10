#check https://github.com/Diego81/omnicontacts for more info

require "omnicontacts"





Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, "1036043446404-rot5smcu95l6gbavhv6md2toe3mg84l4.apps.googleusercontent.com", "yrYF4hGmWQercbtXMs_tAGxb", {:redirect_path => "/contacts/gmail/contact_callback"}
end
