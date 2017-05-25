RailsAdmin.config do |config|
  config.main_app_name = 'The Conversion Doctor'
  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.authenticate_with do
    # Use sorcery's before filter to auth users
    require_login
  end
  config.current_user_method(&:current_user)

  config.authorize_with do
    unless current_user.site_admin?
      flash[:error] = "Sorry you don't have access to the requested page. Please contact your administrator."
      redirect_to '/dashboard'
    end
  end

  config.actions do
    dashboard # mandatory
    index # mandatory
    new do
      except ['Business::Organization']
    end
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.included_models = %w(Business::Organization User SourceType)

  config.model Business::Organization do
    list do
      field :company_name do
        formatted_value do
          path = bindings[:view].show_path(model_name: 'business~organization', id: bindings[:object].id)
          "<a href='#{path}'>#{value}</a>".html_safe
        end
      end
      field :phone
      field :address
      field :owner_id do
        formatted_value do
          User.find(value).full_name
        end
      end
      field :status
      field :total_users do
        formatted_value do
          bindings[:object].users.count
        end
      end
      # field :notification_address
      field :created_at
    end
    show do
      field :company_name
      field :phone
      field :address
      field :city
      field :state
      field :zip
      field :status
      field :created_at
      field :owner_id do
        formatted_value do
          user = User.find(value)
          "#{user.full_name} (#{user.email})"
        end
      end
      # field :notification_address
      field :users do
        pretty_value do
          value.map(&:full_name).join('<br/>').html_safe
        end
      end
    end
    edit do
      field :company_name
      field :phone
      field :address
      field :city
      field :state
      field :zip
      field :status
      # field :notification_address
    end
  end

  config.model 'SourceType' do
    list do
      field :name
      field :created_at
    end
    show do
      field :name
      field :created_at
    end
    edit do
      field :name
    end
  end

  config.model 'User' do
    list do
      field :first_name
      field :last_name
      field :email
      field :organization do
        pretty_value do
          value.present? ? value.company_name : '-'
        end
      end
      field :is_super_admin
      field :is_active
      field :roles do
        formatted_value do
          Business::Role.find(value).map(&:name).join(', ')
        end
      end
      field :created_at
      field :last_login_at
      field :last_login_from_ip_address
    end
    show do
      field :first_name
      field :last_name
      field :email
      field :username
      field :is_super_admin
      field :site_admin
      field :is_active
      field :roles do
        formatted_value do
          Business::Role.find(value).map(&:name).join(', ')
        end
      end
      field :organization do
        pretty_value do
          value.present? ? value.company_name : '-'
        end
      end
      field :created_at
      field :last_login_at
      field :last_login_from_ip_address
    end
    edit do
      field :first_name
      field :last_name
      field :email
      unless :site_admin
        field :is_super_admin
        field :roles do
          partial 'roles'
        end
        field :organization do
          partial 'organizations'
        end
      end
      field :is_active
    end
  end

end
