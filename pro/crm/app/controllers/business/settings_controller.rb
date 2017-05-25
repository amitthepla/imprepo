require 'ringcentral_client'
class Business::SettingsController < BusinessController

  def index
    # puts "@api_client ------------------------"
    # p @api_client = RingCentralClient::RingCentral.new
    # p token = @api_client.authorize_code code

    @surgical_procedures = @current_org.procedures.where(surgical: true).order_by(name: 'asc')
    @medspa_procedures = @current_org.procedures.where(medspa: true).order_by(name: 'asc')
    @products = @current_org.injection_products.order_by(name: 'asc')
    @product = @current_org.injection_products.new
    @procedure = @current_org.procedures.new
    @procedure_types = [%w(Body Body), %w(Face Face), %w(Butt Butt), %w(Breast Breast)]
    sales = @current_org.roles.where({name: 'Sales Coordinator'}).first
    @sales_coordinators = sales.present? ? @current_org.users.where({roles: sales.id.to_s}) : []
    @users = @current_org.users
    @messages = @current_org.email_messages
    @ringcentral_account = @current_org.ringcentral_account
    @mailchimp_account = @current_org.mailchimp_account

    sales = @current_org.roles.where({name: 'Sales Coordinator'}).first
    coordinator_rotation = @current_org.settings.where(:setting_id => 'coordinator_rotation').first
    rotations = coordinator_rotation.present? ? coordinator_rotation.data : []
    available_coordinators = sales.present? ? @current_org.users.where({roles: sales.id.to_s, :_id.nin => rotations}) : []
    rotation_coordinators = sales.present? ? @current_org.users.where({:id.in => rotations}) : []
    @coordinators = {available: available_coordinators, rotation: rotation_coordinators}
    @message_setting = @current_org.settings.where(:setting_id => 'messaging').first.data rescue []
    @coordinator_rotation = coordinator_rotation || @current_org.settings.new
  end

  def update_message_body
    @message = @current_org.email_messages.where(message_id: params[:message_id]).first
    @message.message =  params[:message]
    @message.save

    redirect_to business_settings_path
  end

  def new
    @setting = @current_org.settings.new
  end

  def create
    @setting = @current_org.settings.new
    @setting.name = params[:business_setting][:name]
    @setting.data = params[:coordinators].split(',').map(&:strip)
    notice = @setting.save ? nil : 'Failed to save changes.'
    redirect_to business_settings_path, notice: notice
  end

  def message_setting
    @message_setting = @current_org.settings.where(:setting_id => 'messaging').first || @current_org.settings.new({:name => 'Messaging'})
    data = [params[:second].to_i, params[:third].to_i, params[:migrate_time].to_i]
    @message_setting.data = data
    @message_setting.save

    redirect_to request.referrer
  end

  def update
    @setting = @current_org.settings.find(params[:id])
    @setting.name = params[:business_setting][:name]
    @setting.data = params[:coordinators].split(',').map(&:strip)
    notice = @setting.save ? nil : 'Failed to save changes.'
    redirect_to business_settings_path, notice: notice
  end

  def task_setting
    @deal_stages = Business::Stage.where(:type => 'lead')
  end

  def get_call_type
    grouped_options_for_select(GROUPED_PROCEDURES)
  end

  def revoke_email
    @current_org.email_account.destroy if @current_account.email_account
    redirect_to business_settings_path, notice: 'Successfully revoked access from email.'
  end

  def create_ringcentral
    @ringcentral_account = Business::RingcentralAccount.new(ringcentral_params)
    @ringcentral_account.organization = @current_org
    if @ringcentral_account.save
      flash[:success] = "RingCentral account has been added."
      redirect_to business_settings_path
    else
      flash[:danger] = "Unable to create ringcentral account."
      redirect_to request.referrer
    end
  end

  def destroy_ringcentral
    @current_org.ringcentral_account.destroy if @current_org.ringcentral_account
    redirect_to business_settings_path, notice: 'Successfully removed ringcentral account.'
  end

  def create_mailchimp
    @mailchimp_account = Business::MailchimpAccount.new(mailchimp_params)
    @mailchimp_account.organization = @current_org
    if @mailchimp_account.save
      flash[:success] = 'Mailchimp account has been added.'
      redirect_to business_settings_path
    else
      flash[:danger] = 'Unable to create mailchimp account.'
      redirect_to request.referrer
    end
  end

  def destroy_mailchimp
    @current_org.mailchimp_account.destroy if @current_org.mailchimp_account
    redirect_to business_settings_path, notice: 'Successfully removed mailchimp account.'
  end

  private
  def setting_params
    params.require(:business_setting).permit(:name, :data)
  end

  def ringcentral_params
    params.require(:business_ringcentral_account).permit(:access_key, :secret_key, :phone, :password)
  end

  def mailchimp_params
    params.require(:business_mailchimp_account).permit(:api_key)
  end

end
