Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'admin_constraint'
  mount Sidekiq::Web => "/sidekiq", :constraints => AdminConstraint.new



  get 'errors/not_found'

  get 'errors/internal_server_error'

  mount RailsAdmin::Engine => '/site_admin', as: :rails_admin

  resources :password_resets

  get '/auth/:provider/callback' => 'sessions#create'
  get '/auth/:provider/notes/callback' => 'sessions#set_notes_email'
  get 'password_resets/create'
  get 'password_resets/edit'
  get 'password_resets/update'
  get 'logout' => 'auth#destroy'
  get 'login' => 'auth#new'


  get 'import_realself_emails' => 'business/import#import_realself_emails', as: 'import_realself_emails'
  get 'import_opticall_emails' => 'business/import#import_opticall_emails', as: 'import_opticall_emails'
  get 'receptionist_view_from_leads' => 'business/leads#receptionist_view'
  get 'receptionist_view_from_tasks' => 'business/tasks#receptionist_view'
  get 'coordinator_view_from_leads' => 'business/leads#coordinator_view'
  get 'coordinator_view_from_tasks' => 'business/tasks#coordinator_view'
  get 'promote_lead/:lead_id/:stage' => 'business/leads#promote_lead', as: 'promote_lead'

  post 'login' => 'auth#create'
  post 'auth/pusher' => 'auth#pusher_auth'
  post 'sign_up' => 'organizations#create', as: :create_organization

  get 'sign_up' => 'organizations#new'
  get 'check_username_availability/:username' => 'organizations#check_username_availability'
  get 'check_email_availability' => 'organizations#check_email_availability'

  namespace :marketing do
    resources :reports
    get 'dashboard/view_health_check' => 'dashboard#view_health_check' , as: "view_health_check"
    get 'dashboard/health_check' => 'dashboard#health_check' , as: "health_check"
    get 'dashboard/get_chart/:chart/:view' => 'dashboard#get_chart'
    get 'analytics_data' => 'dashboard#activity_analytics'
    get 'dashboard' => 'dashboard#dashboard'
    get 'analytics' => 'dashboard#index'
    get 'log' => 'log#index'
    get 'log_filter' => 'log#filtered_data_count'
    get 'filtered_log' => 'log#filtered_log'
    get 'filter' => 'dashboard#filtered_data_count'
    get 'diagnostic_filter' => 'dashboard#diagnostic_filter'
    get 'diagnostic' => 'dashboard#diagnostic'
    resources :organizations
    get 'roles' => 'permissions#index'
    get 'roles/:id/edit' => 'permissions#edit', as: :edit_permissions
    post 'role/:id' => 'permissions#update', as: :update_permissions
    resources :users do
      get 'impersonate' => 'users#impersonate'
      get 'stop_impersonating', on: :collection
    end
  end

  namespace :business, path: '/' do
    get 'auth/failure' => 'emails#connect'
    get 'dashboard/analytics/:file' => 'dashboard#analytics_data'
    get 'dashboard/ping' => 'dashboard#ping'

    # start
    get 'emails/connect' => 'emails#connect', as: :email_connect
    get '/emails/:provider/mail' => 'emails#mail', as: :email_mail
    get '/emails/:provider/:mailbox/:id' => 'emails#show_email', as: :email_show_email
    post '/emails/:provider/:id/toggle_star' => 'emails#toggle_star'
    post '/emails/:provider/toggle_unread' => 'emails#toggle_unread'
    post '/emails/:provider/delete_emails' => 'emails#delete_emails'
    post '/emails/:provider/send_mail' => 'emails#send_mail', as: :send_email
    post '/emails/:provider/reply_mail' => 'emails#reply_mail', as: :reply_email
    delete '/emails/:provider/logout' => 'emails#logout', as: :email_logout
    # end

    resources :consultations
    get '/consultations/book/:lead_id' => 'consultations#book', as: :book
    resources :email_messages
    post '/send_message/:id/:lead_id' => 'email_messages#send_message', as: :send_message
    resources :surgeries
    get '/surgeries/book/:lead_id' => 'surgeries#book'
    resources :injection_products
    resources :sources
    resources :bank_profiles
    resources :staff, as: 'users', controller: 'users' do
      collection do
        get 'invites' => 'users#invites'
      end
    end
    resources :tasks
    resources :task_settings
    resources :phone_messages do
      get 'mark_complete'
    end
    resources :events do
      get 'search', on: :collection
    end
    resources :diagnostic_reports
    resources :analytics_reports
    resources :health_check_reports
    resources :leads do
      member do
        get :get_procedure_cost
        get :get_second_procedure_cost
      end
      collection do
        get 'stage_leads' => 'leads#stage_leads'
      end
      get 'questionnaire' => 'leads#show_questionnaire'
      get 'resend_questionnaire' => 'leads#resend_questionnaire'
      get 'send_first_followup_email' => 'leads#send_first_followup_email'
      get 'send_second_followup_email' => 'leads#send_second_followup_email'
      get 'search', on: :collection
      resources :notes, :defaults => {subject: 'lead', subject_id: 'lead_id'}
      resources :tasks
    end
    resources :deals do
      resources :notes, :defaults => {subject: 'deal', subject_id: 'deal_id'}
    end
    resources :patients, as: 'contacts', controller: 'contacts' do
      get 'search', on: :collection
      get 'consult_packet' => 'contacts#consult_packet'
      get 'send_consult_packet' => 'contacts#send_consult_packet'
    end
    scope 'settings' do
      get '/lead_workflow' => 'settings#lead_workflow'
      resources :stages
      resources :sites
      resources :roles do
        match 'save_stages' => 'roles#save_stages', :via => [:get, :post]
      end
      resources :statuses
      resources :procedures
      get 'task_setting' => 'settings#task_setting'
      post 'save_task' => 'settings#save_task'
      get 'get_call_type' => 'settings#get_call_type'
      delete 'revoke_email' => 'settings#revoke_email'
    end
    resources :statuses
    resources :procedures
    get 'task_setting' => 'settings#task_setting'
    post 'save_task' => 'settings#save_task'
    get 'get_call_type' => 'settings#get_call_type'
    delete 'revoke_email' => 'settings#revoke_email'
    post 'create_ringcentral' => 'settings#create_ringcentral'
    delete 'destroy_ringcentral' => 'settings#destroy_ringcentral'
    post 'create_mailchimp' => 'settings#create_mailchimp'
    delete 'destroy_mailchimp' => 'settings#destroy_mailchimp'

    resources :import, only: [:index, :create]
    resources :settings
    resources :casting, only: [:index]
  end

  namespace :api do
    namespace :v1 do
      resources :procedures
      resources :leads
      resources :casting
    end
  end

  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  get 'remarket_results' => 'marketing/remarket#index', as: 'remarket_results'
  get 'remarket' => 'marketing/remarket#new', as: 'remarket'
  post 'mass_text' => 'marketing/remarket#send_mass_text', as: 'mass_text'
  post 'mass_email' => 'marketing/remarket#send_mass_email', as: 'mass_email'
  post 'create_list' => 'marketing/remarket#create_list', as: 'create_list'
  get 'chat_panel' => 'chats#chat_panel'
  get 'chat_history' => 'chats#chat_history'
  get 'conversation_members/:cnv_type' => 'chats#conversation_members'
  get 'get_group_members/:id' => 'chats#get_group_members'
  post 'update_group_name' => 'chats#update_group_name'
  post 'create_channel' => 'chats#create_channel'
  post 'upload_attachment' => 'chats#upload_attachment', as: :upload_attachment
  post 'reset_last_chat_activity' => 'chats#reset_last_chat_activity'

  get 'invite/:id' => 'users#new'
  get 'send_beauty_profile/:id' => 'business/contacts#send_beauty_profile', as: :send_beauty_profile
  post 'submit_photos' => 'business/contacts#photo_submission', as: :submit_photos
  get 'send_photo_request/:id' => 'business/contacts#send_photo_request', as: :send_photo_request
  get 'request_photos/:id' => 'business/contacts#request_photos', as: :request_photos
  get 'questionnaire/:id' => 'business/contacts#questionnaire', as: :questionnaire
  patch 'questionnaire/:id' => 'business/contacts#questionnaire_submission', as: :questionnaire_submission
  get 'generate_html_form/:site_id' => 'business/sites#generate_html_form', as: :generate_html_form
  get 'questionnaire_source_options/:id/:contact_id' => 'business/contacts#source_options', as: :questionnaire_source_options
  get 'source_options/:id' => 'business/leads#source_options', as: :source_options
  post '/save_temp_photos' => 'business/contacts#save_temp_photos'
  get '/display_temp_photos' => 'business/contacts#display_temp_photos'
  delete '/delete_temp_photos' => 'business/contacts#delete_temp_photos'
  get 'consultation/:id' => 'business/contacts#consultation', as: :consultation
  patch 'consultation/:id' => 'business/contacts#consultation_submission', as: :consultation_submission
  get 'thank_you' => 'public#thank_you'
  get 'calendar' => 'public#calendar'
  post 'calendar_submission' => 'business/contacts#calendar_request_submission'
  get 'bprofile' => 'public#bank_profile'
  post 'bprofile_submission' => 'business/bank_profiles#profile_submission'
  post 'edit_procedure_info' => 'business/leads#edit_procedure_info'

  resources :users, only: [:create]

  post 'auto_messaging' => 'business/settings#message_setting'
  post 'not_final_business_task' => 'business/tasks#not_final_task', as: 'not_final_business_task'

  get 'final_business_task/:id/:stage/:lead_id' => 'business/tasks#final_task', as: 'final_business_task'
  get 'complete_task_and_promote_lead/:id/:lead_stage/:task_stage' => 'business/leads#complete_task_and_promote_lead', as: 'complete_task_and_promote_lead'
  get 'new_lead_task_path/:id' => 'business/tasks#new_lead_task', as: 'new_lead_task'
  get 'mark_leads_cold' => 'business/leads#mark_leads_cold', as: 'mark_leads_cold'

  post 'cancel_surgery' => 'business/leads#cancel_surgery', as: 'cancel_surgery'
  post 'reschedule_surgery' => 'business/leads#reschedule_surgery', as: 'reschedule_surgery'
  post 'cancel_consult' => 'business/leads#cancel_consult', as: 'cancel_consult'
  post 'reschedule_consult' => 'business/leads#reschedule_consult', as: 'reschedule_consult'
  post 'complete_surgery' => 'business/leads#complete_surgery', as: 'complete_surgery'

  get 'clone_lead/:id' => 'business/contacts#clone_lead', as: 'clone_lead'

  get 'get_coordinates/:id' => 'business/leads#get_coordinates', as: 'get_coordinates'
  post 'save_treatment/:id' => 'business/leads#save_treatment', as: 'save_treatment'
  post 'book_consult' => 'business/leads#book_consult', as: 'book_consult'
  post 'book_surgery' => 'business/leads#book_surgery', as: 'book_surgery'
  post 'cold_or_dq_lead' => 'business/leads#cold_or_dq_lead', as: 'cold_or_dq_lead'
  post 'move_lead' => 'business/leads#move_lead', as: 'move_lead'
  post 'consult_note' => 'business/leads#consult_note', as: 'consult_note'
  post 'send_text_to_lead' => 'twilio#send_text', as: 'send_text_to_lead'
  post 'send_email_to_lead' => 'business/leads#send_email', as: 'send_email_to_lead'
  post 'update_message_body' => 'business/settings#update_message_body'

  get 'schedule' => 'business/dashboard#calendar', as: 'schedule'
  get 'business_leads_consult_log' => 'business/leads#consult_log', as: 'business_leads_consult_log'
  get 'business_leads_surgery_log' => 'business/leads#surgery_log', as: 'business_leads_surgery_log'
  get 'mday2015_1_viva' => 'landing_pages#mothers_day_viva_1'
  get 'mday2015_2_viva' => 'landing_pages#mothers_day_viva_2'
  get 'free_bag_procedure_summer_2015' => 'landing_pages#free_bag_procedure_summer_2015'

  post 'parse' => 'business/import#parse', as: 'parse'
  post 'import_lead' => 'business/import#import_lead', as: 'import_lead'
  post 'delete_duplicates' => 'business/leads#delete_duplicates', as: 'delete_duplicates'
  post 'receive_text' => 'twilio#receive_text', as: 'receive_text'
  post 'message' => 'business/leads#message', as: 'message'

  get 'archive_message/:id' => 'business/phone_messages#archive_message', as: 'archive_message'
  get 'send_text/:lead' => 'twilio#send_text', as: 'send_text'
  get 'snapshot' => 'marketing/dashboard#snapshot', as: 'snapshot'
  get 'injectable_leads' => 'business/leads#injectable_leads', as: 'injectable_leads'
  get 'duplicate_leads' => 'business/leads#duplicate_leads', as: 'duplicate_leads'

  root 'auth#new'

end
