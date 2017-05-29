SalesCafe::Application.routes.draw do
  resources :community_plugins


  #require 'sidekiq/web'
  #constraints(host: /^(?!www\.)/i) do
  #  match '(*any)' => redirect { |params, request|
  #    URI.parse(request.url).tap { |uri| uri.host = "www.#{uri.host}" }.to_s
  #  }
  #end
  match "/contacts/:importer/contact_callback" => 'contacts#contact_callback', :via => [:get, :post]
  match 'import_contacts' => 'contacts#import_contacts', :via => [:get, :post]  
  get 'home/index'

  # start
  get "/auth/google_oauth2/callback" => 'omniauth_callbacks#google_oauth2'
  get "/auth/linkedin/callback" => 'omniauth_callbacks#linkedin'
  get "/auth/:provider/mailbox/callback" => 'emails#create'
  match '/emails' => 'emails#index'
  get 'emails/connect' => 'emails#connect', as: :email_connect
  get '/emails/:provider/mail' => 'emails#mail', as: :email_mail
  get '/emails/:provider/:mailbox/:id' => 'emails#show_email', as: :email_show_email
  post '/emails/:provider/:id/toggle_star' => 'emails#toggle_star'
  post '/emails/:provider/toggle_unread' => 'emails#toggle_unread'
  post '/emails/:provider/delete_emails' => 'emails#delete_emails'
  post '/emails/:provider/send_mail' => 'emails#send_mail', as: :send_email
  post '/emails/:provider/reply_mail' => 'emails#reply_mail', as: :reply_email
  delete '/emails/:provider/logout' => 'emails#logout', as: :email_logout
  match '/auth/failure' => 'emails#failure' 
  # end
  # match 'users/sign_up' => 'home#index', :via => [:get]
  #devise_for :users, :controllers => {:registrations => 'registrations'}
  #, :omniauth_callbacks => "omniauth_callbacks"
  devise_for :users, :controllers => {:registrations => "registrations",:passwords => "passwords"}, path: '', path_names: { sign_in: 'users/sign-in', sign_up: 'users/sign-up'}
  match '/users/sign_up', to: redirect('/users/sign-up', status: 301)
  match '/users/sign_in', to: redirect('/users/sign-in', status: 301)
  post '/resend_invite', to: 'users#resend_invite', as: 'resend_invite'
  match '/contacts/failure' => 'contacts#import_failure'
  resources :settings
  post 'settings/save_group' => 'settings#save_group'
  post 'settings/delete_group' => 'settings#delete_group'
  post 'settings/delete_label' => 'settings#delete_label'
  post 'settings/get_group' => 'settings#get_group'
  post 'settings/save_source' => 'settings#save_source', :as => 'save_source'
  post 'settings/save_industry' => 'settings#save_industry', :as => 'save_industry'
  post 'settings/save_label' => 'settings#save_label', :as => 'save_label'
  post 'settings/save_user_label' => 'settings#save_user_label', :as => 'save_label'
  post 'settings/get_user_label' => 'settings#get_user_label'
  post 'settings/get_task_outcome_label' => 'settings#get_task_outcome_label'
  post 'settings/save_task_outcome_label' => 'settings#save_task_outcome_label'
  post 'settings/delete_taskoutcome' => 'settings#delete_taskoutcome'

  match '/update_weekly_digest' => 'settings#update_weekly_digest', :via => [:get, :post]
  match '/unscribe_latest_blog' => 'settings#unscribe_latest_blog', :via => [:get, :post]
  match 'settings/update_priority_org' => 'settings#update_priority_org', :via => [:get, :post]
  match 'settings/update_lead_status' => 'settings#update_deal_status', :via => [:get, :post]
  match 'settings/update_feed_keyword_org' => 'settings#update_feed_keyword_org', :via => [:get, :post]
  match 'settings/add_lead_stage' => 'settings#add_lead_stage', :via => :post
  match 'settings/update_lead_stages' => 'settings#update_lead_stages', :via => :post
  match 'settings/update_stage_sequence' => 'settings#update_stage_sequence', :via => :post
  match 'settings/update_widget_org' => 'settings#update_widget_org', :via => [:get, :post]
  match 'settings/update_notification' => 'settings#update_notification', :via => [:get, :post]
  match 'settings/fetch_pages' => 'settings#fetch_pages', :via => [:get, :post]
  match 'update_org_settings' => 'settings#update_org_settings'
  match 'get_contacts/:org_id' => 'application#get_contacts'
  match 'settings/edit_source' => 'settings#edit_source'
  match 'settings/edit_industry' => 'settings#edit_industry'
  match 'edit_company_contact/:id' => 'contacts#edit_company_contact'
  match 'edit_individual_contact/:id' => 'contacts#edit_individual_contact'
  match 'edit_ind_contact' => 'contacts#edit_ind_contact'
  match 'getting_started' => 'home#getting_started'
  match 'daily_updates' => 'home#daily_updates'  
  match 'clear_cache' => 'home#clear_cache'
  match 'load_header_count_section' => 'home#load_header_count_section'
  match 'pie_donut_chart' => 'home#pie_donut_chart'
  match 'line_chart_display' => 'home#line_chart_display'
  match 'summary' => 'home#summary'
  match 'features' => 'home#features'
  match 'lead_statistics_info' => 'home#deal_statistics_info'
  match 'pie_chart_display' => 'home#pie_chart_display'
  match 'funnel_chart_display' => 'home#funnel_chart_display'
  match 'task_widget_page' => 'home#task_widget_page'
  match 'header_user_info' => 'application#header_user_info'
  match 'load_all_partials' => 'application#load_all_partials'
  match 'lead_contacts_info' => 'deals#deal_contacts_info'
  match 'leads/setting' => 'deals#deal_setting', :via => [:post]
  match 'created_by_user' => 'deals#created_by_user'
  match 'lead_location_filter' => 'deals#deal_location_filter'
  match 'assigned_lead_leaderboard' => 'deals#assigned_deal_leaderboard'
  match 'upload_multiple_note_attach' => 'deals#upload_multiple_note_attach'
  match 'delete_temp_note_attach' => 'deals#delete_temp_note_attach'
  match 'send_weekly_digest_email' => 'deals#send_weekly_digest_email'
  match 'change_lead_status' => 'deals#change_lead_status'
  match 'get_lead_details_in_lead_listing' => 'deals#get_lead_details_in_lead_listing'
  match 'change_priority' => 'deals#change_priority'
  match 'change_user_label' => 'deals#change_user_label'
  match 'add_attchment_to_lead' => 'deals#add_attchment_to_lead'
  match 'get_lead_stages' => 'deals#get_lead_stages'
  match 'change_lead_stage' => 'deals#change_lead_stage'
  match 'change_lead_stage_in_lead_details' => 'deals#change_lead_stage_in_lead_details'
  match 'leads/kanban' => 'deals#index'
  match '/get_kanban_stages' => 'deals#get_kanban_stages', :via => [:post]
  match 'tab_settings_in_kanban' => 'deals#tab_settings_in_kanban', :via => [:post]

  match "leads/:id" => 'deals#update', :via => [:post]


  authenticated :user do
    root :to => 'home#dashboard'
  end
  # devise_scope :user do
  #   root :to => 'devise/sessions#new'
  # end
  root :to => 'home#index'
  match '/notfound' => 'home#notfound'

  #match '/pricing' => 'home#pricing'
  match '/terms' => 'home#terms'
  match '/privacy' => 'home#privacy'
  match '/security' => 'home#security'
  match '/contact-us' => 'home#contact_us'
  match '/activities' => 'home#activities'
  match '/api_contact_us' => 'home#api_contact_us', :via => [:post]
  match '/integrations' => 'home#integration'
  match 'send_feedback' => 'home#send_feedback'
  match 'about-us' => 'home#about_us'
  match 'roadmap' => 'home#roadmap'
  match 'product-updates' => 'home#releases'
  match 'report-a-bug' => 'home#report_a_bug'
  match '/save_bug_report' => 'home#save_bug_report'
  match '/sitemap' => 'home#sitemap'
  match '/subscription_test' => 'home#subscription_test' 

  match '/reset_subscription' => 'home#reset_subscription' 
  match '/lambda_test' => 'home#lambda_test'
  


  match '/contact_us', to: redirect('/contact-us', status: 301)

  get 'dashboard' => 'home#dashboard', :as => 'dashboard'
  get 'organizations' => 'home#organizations', :as => 'organizations'
  match '/organization/:id/users' => 'users#index'
  match '/task_widget' => 'home#task_widget'
  match '/lead_task_widget' => 'deals#deal_task_widget'
  match '/task_widget_reload' => 'deals#task_widget_reload'
  match '/get_activities' => 'home#get_activities'
  match '/usage' => 'home#usage'
  match '/faqs' => 'home#faq'
  match '/awards-and-recognitions' => 'home#awards_and_recognitions'
  match '/pricing' => 'home#pricing'

  resources :contacts do
    get :autocomplete_first_name, :on => :collection

  end

  match 'add_contact_form' => 'contacts#add_contact_form', :via => [:post]
  match 'get_companies/:org_id' => 'application#get_companies'
  match 'company_contact' => 'contacts#company_contact_detail'
  match 'individual_contact' => 'contacts#individual_contact_detail'
  match 'contact/:id' => 'contacts#show_contact_detail'

  resources :contacts
  match 'contacts/change_status/:id' => 'contacts#change_status', :via => [:post]
  match 'get_all_contacts' => 'contacts#get_all_contacts', :via => [:GET]
  match 'get_more_contacts' => 'contacts#get_more_contacts', :via => [:post], :as => 'get_more_contacts'
  match 'contact_widget' => 'contacts#contact_widget', :via => [:post]
  match 'get_contact_ajax' => 'contacts#get_contact_ajax', :via => [:post]
  match 'save_contact_timezone' => 'contacts#save_contact_timezone'  
  match 'imported_contacts' => 'contacts#imported_contacts', :via => [:get,:post] 
  match 'import_contact_from_sugar_crm' => 'contacts#import_contact_from_sugar_crm', :via => [:get,:post] 
  match 'import_contact_from_zoho_crm' => 'contacts#import_contact_from_zoho_crm', :via => [:get,:post] 
  match 'import_contact_from_fatfree_crm' => 'contacts#import_contact_from_fatfree_crm', :via => [:get,:post] 
  match 'import_contact_from_other_crm' => 'contacts#import_contact_from_other_crm', :via => [:get,:post] 
  match 'import_bulk_contact' => 'contacts#import_bulk_contact', :via => [:get,:post] 
  match 'imported_bulk_contacts' => 'contacts#imported_bulk_contacts', :via => [:get,:post] 
  match 'proceed_to_bulk_contacts_lead' => 'contacts#proceed_to_bulk_contacts_lead', :via => [:get] 
  match 'fetch_more_contacts' => 'contacts#fetch_more_contacts', :via => [:post], :as => 'get_more_contacts'
  
  match 'proceed_to_lead' => 'contacts#proceed_to_lead', :via => [:get]
  match '/create_contact_opportunity' => 'contacts#create_contact_opportunity', :via => [:post]
  match 'opportunity_to_lead/:id' => 'contacts#opportunity_to_lead'
  


  
  resources :users, :except => [:show]
  match 'get_user_email' => 'users#get_user_email'
  match 'profile' => 'users#profile'
  match 'profile/:id' => 'users#profile'

  match '/display_list_view' => 'contacts#display_list_view' , :via => [:get]
  match '/display_grid_view' => 'contacts#display_grid_view' , :via => [:get]
  match 'assign_unassign_deals' => 'users#assign_unassign_deals', :via => [:post]
  match 'get_daily_update_form' => 'deals#get_daily_update_form', :via => [:get]
  match 'save_daily_updates' => 'users#save_daily_updates', :via => [:post]
  match 'manage_daily_updates' => 'users#manage_daily_updates'
  match 'edit_daily_update' => 'users#edit_daily_update'
  match 'delete_daily_update/:id' => 'users#delete_daily_update', :via => [:delete], :as => 'delete_daily_update'
  match '/create_admin_user' => 'users#create_admin_user', :via => [:post]
  match 'users/pricing' => 'users#pricing'
  

  match '/download_user' => 'home#download_user', :as => 'download_user'
  match 'source_list' => 'users#source_list', :as => 'source_list'
  match 'plugin_integration' => 'users#plugin_integration', :as => 'plugin_integration'
  match 'industry_list' => 'users#industry_list', :as => 'industry_list'
  match '/change_password' => 'users#change_password'
  match '/save_password' => 'users#save_password', :via => [:put]
  match 'invite_user' => 'users#invite_user'
  match 'get_source_list' => 'users#get_source_list', :via => [:post], :as => 'get_source_list'
  match 'get_industry_list' => 'users#get_industry_list', :via => [:post], :as => 'get_industry_list'
  match 'delete_source/:id' => 'users#delete_source'
  match 'delete_industry/:id' => 'users#delete_industry'
  match 'save_profile_info' => 'users#save_profile_info'
  match 'edit_user' => 'users#edit_user'
  match 'assign_deal_to_user' => 'users#assign_deal_to_user'
  match 'resend_invitation' => 'users#resend_invitation'
  match 'load_header_count_user' => 'users#load_header_count_user'
  match 'enable_user/:id' => 'users#enable_usr'
  match 'user_save_tmp_img' => 'users#save_tmp_img'
  match 'update_profile_image' => 'users#update_profile_image'
  match 'block_unblock_user' => 'users#block_unblock_user'
  match 'grant_revoke_admin' => 'users#grant_revoke_admin'
  match 'remove_lead' => 'users#remove_lead'
  match 'get_users_dual_list' => 'users#get_users_dual_list'
  match 'update_active_inactive_users' => 'users#update_active_inactive_users', :via => [:post]

  resources :tasks
  match 'calendar_task' => 'tasks#calendar_task'
  match 'calendar_data' => 'tasks#calendar_data'
  match 'task_tab_data' => 'tasks#task_tab_data'
  match 'reschedule_task' => 'tasks#reschedule_task'

  match 'complete' => 'tasks#complete', :via => [:post]
  match 'edit_task' => 'tasks#edit_task'
  match 'follow_up_task' => 'tasks#follow_up_task'
  match 'start_task' => 'tasks#start_task', :via => [:post]
  match 'all_task' => 'tasks#all_task', :via => [:post]
  match 'today_task' => 'tasks#today_task', :via => [:post]
  match 'overdue_task' => 'tasks#overdue_task', :via => [:post]
  match 'upcoming_task' => 'tasks#upcoming_task', :via => [:post]
  match 'task_listing' => 'tasks#task_listing', :via => [:post]
  match 'task_filter' => 'tasks#task_filter', :via => [:post]
  match 'get_task_details' => 'tasks#get_task_details'
  match 'fetch_tasks' => 'tasks#fetch_tasks', :via => [:get]


  match 'get_task_type' => 'tasks#get_task_type'
  match 'change_task_type' => 'tasks#change_task_type'

  match '/get_sqllite_task' => 'tasks#get_sqllite_task'
  match 'get_inactive_leads' => 'deals#get_inactive_deals'
  
  resources :deals, path: :leads, as: :leads
  match '/move_lead' => 'deals#move_lead'
  match 'leads/apply_label_to_lead' => 'deals#apply_label_to_deal', :via => [:post]
  match 'leads/apply_label_to_single_lead' => 'deals#apply_label_to_single_deal', :via => [:post]
  
  match 'get_incoming_leads' => 'deals#get_incoming_deals', :via => [:post], :as => 'get_incoming_leads'
  match 'get_working_on_leads' => 'deals#get_working_on_deals', :via => [:post], :as => 'get_working_on_leads'
  match 'get_won_leads' => 'deals#get_won_deals', :via => [:post], :as => 'get_won_leads'
  match 'get_lost_leads' => 'deals#get_lost_deals', :via => [:post], :as => 'get_lost_leads'
  match 'get_junk_leads' => 'deals#get_junk_deals', :via => [:post], :as => 'get_junk_leads'
  match 'get_un_assigned_leads' => 'deals#get_un_assigned_deals', :via => [:post], :as => 'get_un_assigned_leads'
  match 'get_other_leads' => 'deals#get_other_deals', :via => [:post], :as => 'get_other_leads'

  match 'get_contact' => 'deals#get_contact', :via => [:post]
  match 'edit_lead' => 'deals#edit_deal', :via => [:post]
  match 'delete_selected_leads' => 'deals#delete_selected_deals'
  match 'get_qualify_leads' => 'deals#get_qualify_deals', :via => [:post], :as => 'get_qualify_leads'
  match 'get_not_qualify_leads' => 'deals#get_not_qualify_deals', :via => [:post], :as => 'get_not_qualify_leads'
  match 'get_leads/:org_id' => 'application#get_deals'
  match 'learnmore' => 'deals#learnmore'
  match 'add_contact' => 'deals#add_contact'
  match 'delete_lead_con/:id' => 'deals#delete_deal_con'
  match 'update_lead_ttl' => 'deals#update_deal_ttl'
  match 'update_note_ttl' => 'deals#update_note_ttl'
  match 'fetch_activity' => 'deals#fetch_activity'
  match 'fetch_user_leads' => 'deals#fetch_user_deals'
  match 'get_industry_list' => 'deals#get_industry_list'
  match 'save_lead_industry' => 'deals#save_deal_industry'
  match 'get_country_list' => 'deals#get_country_list', :as => 'get_country_list'
  match 'save_country_lead' => 'deals#save_country_lead', :as => 'save_country_lead'
  match 'get_user_list_lead' => 'deals#get_user_list_lead', :as => 'get_user_list_lead'
  match 'save_user_lead' => 'deals#save_user_lead', :as => 'save_user_lead'
  match 'save_compsize_lead' => 'deals#save_compsize_lead', :as => 'save_compsize_lead'
  match 'quick_lead' => 'deals#quick_deal', :via => [:post]
  match 'change_assigned_to' => 'deals#change_assigned_to', :as => 'change_assigned_to'
  match 'get_task_type_lead' => 'deals#get_task_type_lead', :as => 'get_task_type_lead'
  match 'save_task_type_lead' => 'deals#save_task_type_lead', :as => 'save_task_type_lead'
  match 'accept_lead' => 'deals#accept_assign_deal'
  match 'deny_lead' => 'deals#deny_assign_deal'

  match 'leads_woking_on/:id' => 'deals#deals_woking_on', :via => [:post]
  match 'bulk_lead_upload' => 'deals#bulk_lead_upload', :via => [:post]
  match 'lead_preview' => 'deals#lead_preview', :via => [:get, :post], :except => [:show]
  match 'destroy_lead' => 'deals#destroy_all_lead'
  match 'save_lead' => 'deals#save_lead'
  match 'save_lead_phone' => 'deals#save_lead_phone'
  match 'save_lead_email' => 'deals#save_lead_email'
  match 'save_lead_data' => 'deals#save_lead_data'
  match '/edit_note' => 'deals#edit_note'
  match '/delete_note_attachment/:id' => 'deals#delete_note_attachment'
  match '/lead_files' => 'deals#deal_files'
  match '/lead_detail_contacts' => 'deals#deal_detail_contacts'
  match 'reassign_user_to_deals' => 'deals#reassign_user_to_deals'
  match '/hide_note' => 'deals#hide_note'

  match 'search_result' => 'search#show'
  match 'search_all' => 'search#search_all'
  resources :search

  match 'fetch_notification_count' => 'home#fetch_notification_count'

  # resources :contacts, :except => :show do
  #  collection do
  #    get :add_notes
  #    post :add_notes
  #  end
  # end


  # match 'contacts/add_notes'=>'contacts#add_notes', :via => [:get,:post]


  match 'add_notes' => 'application#add_notes', :via => [:post]
  match 'send_email' => 'contacts#send_email', :via => [:get, :post]
  match 'get_extension' => 'application#get_extension'
  match 'get_country_states' => 'application#get_country_states'
  match 'attention_notification' => 'application#attention_notification'
  match 'render_notification_area' => 'application#render_notification_area'

  resources :reports
  match 'get_funnel_chart' => 'reports#get_funnel_chart'
  match 'get_user_list_leaderboard' => 'reports#get_user_list_leaderboard'
  match 'get_leads_won' => 'reports#get_deals_won'
  match 'pie_tag_chart' => 'reports#pie_tag_chart'
  match 'report_pdf' => 'reports#report_pdf'
  match 'get_sales_analytic' => 'reports#get_sales_analytic'
  match 'get_lead_report' => 'reports#get_lead_report'
  match 'lead_age_bar_chart' => 'reports#lead_age_bar_chart'

  resources :beta_accounts
  match 'save_user' => 'beta_accounts#save_user'
  match 'new_organization' => 'beta_accounts#new_organization'
  match 'update_organization' => 'beta_accounts#update_organization'
  match 'cancel_organization' => 'beta_accounts#cancel_organization'

  match 'bconfirm' => 'beta_accounts#verify_user'
  match 'approve/:buser_id' => 'beta_accounts#approve'
  match 'disapprove/:buser_id' => 'beta_accounts#disapprove'
  match 'bsignup' => 'home#index'

  #API routes
  match 'api/createLead' => 'api#createLead', :via => [:post]
  match 'api/create_download_lead' => 'api#create_download_lead', :via => [:post]
  match '/create_web_form_lead' => 'api#create_web_form_lead', :via => [:post]
  match '/send_latest_blog_mail' => 'home#send_latest_blog_mail', :via => [:get, :post]
  match 'delete_stage/:id' => 'settings#delete_stage'
  match 'edit_status' => 'settings#edit_status'
  match '/update_current_lead_status' => 'settings#update_current_lead_status', :via => [:post]
  match 'settings/update_stage_sequence_in_setting' => 'settings#update_stage_sequence_in_setting', :via => :post
  match '/deals/get_list_view' => 'deals#get_list_view', :via => [:get, :post]
  match '/deals/get_kanban_view' => 'deals#get_kanban_view', :via => [:get, :post]
  match '/deals/get_deal_funnel' => 'deals#get_deal_funnel', :via => [:get, :post]
  match '/deals/create_lead_ticket/:id' => 'deals#create_lead_ticket', :via => [:post]

  match 'user/add_plug_in/:id' => 'users#add_plug_in', :via => [:get, :post]

  match 'delete_lead/:id' => 'deals#delete_lead'

  match 'delete_task_type/:id' => 'settings#delete_task_type'
  match '/update_task_type' => 'settings#update_task_type', :via => [:post]

  match '/add_task_type' => 'settings#add_task_type', :via => [:post]
  match 'find_code_for_javascript' => 'settings#find_code_for_javascript', :via => [:get] 
  match 'enable_api' => 'settings#enable_api', :via => [:post], as: :enable_api
  match 'disable_api' => 'settings#disable_api', :via => [:delete], as: :disable_api
  match '/test_invoice' => 'invoice#test'
  
  match 'invoice/create' => 'invoice#index'
  match 'create_invoice' => 'invoice#create_invoice'
  match 'resend_invoice/:id' => 'invoice#resend_invoice'
  match 'paid_invoice/:id' => 'invoice#paid_invoice'
  match 'cancel_invoice/:id' => 'invoice#cancel_invoice'
  match '/invoice/get_bill_to_details/' => 'invoice#get_bill_to_details', :via => [:post]
  match '/manage_invoice' => 'invoice#manage_invoice'
  match '/download_invoice' => 'invoice#download_invoice', :via => [:GET]
  match '/check_unique_invoice' => 'invoice#check_unique_invoice', :via => [:GET]
 
  # Files
  match 'files' => 'files#index'
  match 'get_all_leads' => 'files#get_all_leads'
  match 'filter_files_by_lead' => 'files#filter_files_by_lead'
  match 'load_all_files' => 'files#load_all_files'
  match 'filter_file_on_date_range' => 'files#filter_file_on_date_range'
  match 'get_all_users' => 'files#get_all_users'
  match 'filter_files_by_user' => 'files#filter_files_by_user'



  resources :community_plugins
  match 'plugin/:plug_id/checkout' => 'community_plugins#checkout'
  match 'plugin/:plug_id/pay' => 'community_plugins#pay', :via => [:post]
  match 'plugin/:token/download' => 'community_plugins#download', :via => [:get]
  

  # match '/emails' => 'emails#index'
  # match '/emails/connect' => 'emails#connect', as: :email_connect
  
  # Website Integration
  match "/web_form/create" => "web_form#new"
  match "/manage_web_form" => "web_form#index"
  match "/create_web_form" => "web_form#create"
  match "/web_form/thank_you" => "web_form#thank_you"
  match "/web_form/generate_form/" => "web_form#generate_form"
  match "web_form/enable_disable_form/:form_unique_id" => "web_form#enable_disable_form"
  match "/get_html_code" => "web_form#get_html_code"
  

  post "subscriptions/create"
  post "subscriptions/cancel"
  post "subscriptions/update"
  match '/webhook' => 'subscriptions#webhook'
  match '/check_trial_period_expiration' => 'subscriptions#check_trial_period_expiration'  
  match "/users/subscription" => "subscriptions#subscription"
  match "/subscription/cancel" => "subscriptions#cancel"
  match "/users/transactions" => "subscriptions#transactions"
  match '/org_trial_form' => 'home#org_trial_form'
  match '/update_org_trial' => 'home#update_org_trial'
  match "/users/credit_card" => "subscriptions#credit_card"
  match "/users/edit_credit_card" => "subscriptions#edit_credit_card"
  match "/users/update_credit_card" => "subscriptions#update_credit_card"
  match "/users/download_invoice/:invoice_id" => "subscriptions#download_invoice"
  match "/get_invoice_email" => "subscriptions#get_invoice_email"



  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with 'root'
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with 'rake routes'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  # match ':rest' => 'application#page_not_found_error', :constraints => { :rest => /.*/ }
  # match 'contact_callback' => 'contacts#contact_callback'
  #match 'import_contacts' => 'contacts#import_contacts'
  match 'testgmail' => 'contacts#testgmail' #,:via=>[:post]
  # match '/contacts/:importer/callback' => 'contacts#callback'
  # match 'contacts/:provider/contact_callback' => 'contacts#contact_callback'
  # match 'contacts/invite_contacts' =>'contacts#invite_contacts'
  # mount Sidekiq::Web, at: '/sidekiq'
  


end
