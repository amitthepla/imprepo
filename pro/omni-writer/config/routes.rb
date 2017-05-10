Rails.application.routes.draw do


  devise_for :users, :controllers => { :registrations => "users/registrations", :sessions =>  "users/sessions"}

  # You can have the root of your site routed with "root"
  # root 'contents#index'
  devise_scope :user do
    authenticated :user do
      root to: "contents#index", :as => "authenticated"
    end

    unauthenticated do
      root to: "devise/sessions#new", :as => "unauthenticated"
    end
  end


  get 'fetch_templates' => 'contents#fetch_templates'
  post 'upload' => 'contents#upload_file'
  get '/download' => 'contents#download'
  get 'assets' => 'assets#index'
  post 'upload_asset' => 'assets#upload_asset'
  delete 'destroy_asset' => 'assets#destroy'

  get "users/change_password", to: "admin/users#change_password"
  put "users/change_password", to: "admin/users#change_password"

  namespace :admin do 
    get "users", to: "users#index"
    post "invite", to: "users#invite"
    put "block", to: "users#block"
    put "unblock", to: "users#unblock"
    put "resend_invitation", to: "users#resend_invitation"
  end


end
