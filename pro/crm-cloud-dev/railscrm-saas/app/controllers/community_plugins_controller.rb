class CommunityPluginsController < ApplicationController
  #http_basic_authenticate_with name: "john", password: "andola#123$", :only => [:checkout]
  include CommunityPluginsHelper
  TRANSACTION_SUCCESS_STATUSES = [
    Braintree::Transaction::Status::Authorizing,
    Braintree::Transaction::Status::Authorized,
    Braintree::Transaction::Status::Settled,
    Braintree::Transaction::Status::SettlementConfirmed,
    Braintree::Transaction::Status::SettlementPending,
    Braintree::Transaction::Status::Settling,
    Braintree::Transaction::Status::SubmittedForSettlement,
  ]

  before_filter :set_community_plugin, only: [:show, :edit, :update, :destroy]
  skip_before_filter :authenticate_user!, only: [:checkout, :pay, :download]

  layout 'application', :except => [:checkout,:pay]

  respond_to :html

  def index
    @community_plugins = CommunityPlugin.all #where("is_plugin=?",true)
    respond_with(@community_plugins)
  end

  def show
    respond_with(@community_plugin)
  end

  def new
    @community_plugin = CommunityPlugin.new
    respond_with(@community_plugin)
  end

  def edit
  end

  def create
    @community_plugin = CommunityPlugin.new(params[:community_plugin])
    @community_plugin.save
    redirect_to "/community_plugins"
  end

  def update
    @community_plugin.update_attributes(params[:community_plugin])
    respond_with(@community_plugin)
  end

  def destroy
    @community_plugin.destroy
    respond_with(@community_plugin)
  end

  def checkout
      if(@plugin = CommunityPlugin.where(unique_id: params[:plug_id]).first).present?
        @client_token = Braintree::ClientToken.generate
      else
        flash[:bodanger] = "Invalid Plugin URL"
        redirect_to root_path
      end
  end

  def pay
   #{"utf8"=>"â", "authenticity_token"=>"r4/TOpRieYB4w8se+0Vu506yMvqX0hiT1LeD5LGC80c=", "amount"=>"434", "email"=>"sdsd@dsd.com", "card_number"=>"4000111111111115", "card_holder_name"=>"Amit", "exp_month"=>"12", "exp_year"=>"2017", "CVV2"=>"343", "commit"=>"Pay", "gmt_offset"=>"5.5", "lat"=>"0.0", "long"=>"0.0", "remote_ip"=>"111.93.178.162", "country"=>"IN", "city"=>"", "state"=>"", "controller"=>"community_plugins", "action"=>"pay", "plug_id"=>"dcdec8e49528fb634f3caeb7124c75ed"}

    puts "---------> params <-----------"
    p params
    p request.ip
    p request.location
    p request.remote_ip
    respond_to do |format|
    # begin 
      if params[:plug_id].present? && params[:card_holder_name].present? && params[:email].present? && params[:card_number].present? && params[:exp_month].present? && params[:exp_year].present? && params[:CVV2].present?
        if(@plugin = CommunityPlugin.where(unique_id: params[:plug_id]).first).present?
          result = Braintree::Transaction.sale(
              :amount => @plugin.price,
              :customer => {
                :first_name => params[:card_holder_name],
                :email => params[:email]
              },
              :credit_card => {
                :number => params[:card_number],
                :cardholder_name =>params[:card_holder_name],
                :expiration_date => "#{params[:exp_month]}/#{params[:exp_year]}",
                :cvv => params[:CVV2]
              },
              :options => {
                :submit_for_settlement => true
              }
            )       
          # p result.transaction.id
          if result.success?        
            puts "---success"
             p result
             # Notification.plugin_payment_success(@plugin.name).deliver
             # Notification.admin_plugin_payment_notification(params[:card_holder_name], params[:email], @plugin.name, params[:gmt_offset]).deliver
             #################logic to save in plugin transaction table############

             # {"utf8"=>"✓", "authenticity_token"=>"p7fpZN09GgN4Jt2QM6reMdgJofWNg5HkIFcXI2RUpnM=", "amount"=>"1", "email"=>"sdsd@dsd.com", "card_number"=>"4009348888881881", "card_holder_name"=>"Amit", "exp_month"=>"12", "exp_year"=>"2017", "CVV2"=>"422", "commit"=>"Pay", "gmt_offset"=>"5.5", "lat"=>"22.5697", "long"=>"88.3697", "remote_ip"=>"111.93.178.162", "country"=>"IN", "city"=>"", "state"=>"", "controller"=>"community_plugins", "action"=>"pay", "plug_id"=>"cec65b31344a1237f1da9ae94e5eee67"}
             @plugin_trans = PluginTransaction.create(:name => params[:card_holder_name], :email => params[:email], :phone => params[:phone], :gmt_offset => params[:gmt_offset], :ip => params[:remote_ip], :community_plugin_id => @plugin.id, :invoice_id => generate_invoice_id, :transaction_status => "Success" )
             begin
              result = Geocoder.search("")
              if result.first.present? && (geo_code = result.first.data).present?
                location = ""
                location += geo_code["region_name"] + "," if geo_code["region_name"].present? 
                location += geo_code["city"] + "," if geo_code["city"].present?
                location += geo_code["country_name"] if geo_code["country_name"].present?

                @plugin_trans.update_attributes(:latitude => geo_code["latitude"],:longitude => geo_code["longitude"], :location => location, :ip => geo_code["ip"])
              end
              if @plugin.is_plugin
                Notification.admin_plugin_payment_notification(@plugin_trans.name, @plugin_trans.email, @plugin.name, geo_code).deliver
              end
             rescue
             end
             ######################################################################
             # flash[:bosuccess] = "You have been successfully purchased addon. Please check your mail for download link."           
             format.json { head :no_content }
             # redirect_to "/"
             #redirect_to "/plugin/#{params[:plug_id]}/checkout"
          else
            Notification.plugin_payment_error(params[:card_holder_name], params[:email], @plugin, result.message).deliver
            # redirect_to "/plugin/#{params[:plug_id]}/checkout"
            format.json { render text: result.message, status: :unprocessable_entity }
            
          end
         else
           format.json { render text: "Plugin not found!!!", status: :unprocessable_entity }
           # redirect_to "/plugin/#{params[:plug_id]}/checkout"
         end
      else
        format.json { render text: "Required parameters missing.", status: :unprocessable_entity }
      end     
    end
    # rescue => e
    #     flash[:bodanger] = e.message
    #     redirect_to "/plugin/#{params[:plug_id]}/checkout"
    # end
  end

  def update_location
    location=""
    location += params[:city] + ", " if params[:city].present?
    location += params[:state] + ", " if params[:state].present?
    location += params[:country] if params[:country].present?
    return location
  end

  def generate_invoice_id
    plugin_trans = PluginTransaction.last
    if plugin_trans.present? && plugin_trans.invoice_id.present?
      plugin_trans.invoice_id + 1
    else
      3000
    end
  end

  def download
    if(@plugin_trans = PluginTransaction.where(token: params[:token]).first).present?
      if (plugin = @plugin_trans.community_plugin).present?
        zip_file = return_zip_file plugin.name
        begin
          send_file(
            "/var/www/shared/" + zip_file,
            filename: zip_file,
            type: "application/zip"
          )
          @plugin_trans.update_attributes(:download_date => Time.now, :download_count => @plugin_trans.download_count + 1)
        rescue => e
          flash[:bodanger] = e.message
          redirect_to "/"
        end
      else
        flash[:bodanger] = "Plugin not found!!!"
        redirect_to "/"
      end
    else
      flash[:bodanger] = "Invalid token!!!"
      redirect_to "/"
    end
  end

  private
    def set_community_plugin
      @community_plugin = CommunityPlugin.find(params[:id])
    end
end
