class SubscriptionsController < ApplicationController
  before_filter :authenticate_admin, :except => [:webhook, :check_trial_period_expiration]
  skip_before_filter :authenticate_user!, :only => [:webhook, :check_trial_period_expiration]
  skip_before_filter :chk_subscription_status_and_user_limit
  skip_before_filter :is_trial_expired
  before_filter :assign_user, :except => [:webhook, :check_trial_period_expiration]
  before_filter :authenticate_super_admin, :only => [:subscription, :transaction]



  def create
    my_logger ||= Logger.new("#{Rails.root}/log/payment.log")
    my_logger.info("--------subscription create---"+ Time.now.to_s + "-----------")
    respond_to do |format|
    begin
      #respond_to do |format|
         begin
           result = Braintree::Customer.create(
              :first_name => params[:card_holder_name],
              :last_name => '',
              :email => @current_user.email,
              :phone => '',
              :company => @current_organization.name,
              :credit_card => {
                :number => params[:card_number],
                :cardholder_name => params[:card_holder_name],
                :expiration_date => "#{params[:exp_month]}/#{params[:exp_year]}",
                :cvv => params[:CVV2],
                :options => {
                  :verify_card => true
                },
                :billing_address => {
                  :company => @current_organization.name,
                  :street_address => params[:street_address],
                  :locality => params[:city],
                  :region =>params[:state],
                  :postal_code => params[:zipcode],
                  :country_code_alpha2 => params[:country_code_alpha2]
                }         
              }
            )
          rescue => e
            my_logger.info("Exception in BT profile creation "+ "Message -> "+e.message)
            my_logger.info("organization Name"+@current_organization.name.to_s)
            my_logger.info("organization ID"+@current_organization.id.to_s)
            my_logger.info("User ID"+@current_user.id.to_s)
            format.json { render json: e.message, status: :unprocessable_entity }
          end
          user_limit = params[:user_limit]
          ###Check trial period expiration############# 

          #############################################
          if result.success?    
            begin    
              if @current_organization.trial_expired?
                   result_plan = Braintree::Subscription.create(
                          :payment_method_token => result.customer.credit_cards.first.token,
                          :plan_id => 'rr9r',
                          :price => params[:price]
                   )
                 
              else
                   result_plan = Braintree::Subscription.create(
                          :payment_method_token => result.customer.credit_cards.first.token,
                          :plan_id => 'rr9r',
                          :price => params[:price],
                          :trial_duration => @current_organization.trail_days_left_in_days,
                          :trial_period => true,
                          :trial_duration_unit => 'day'
                   )
                 
              end
            rescue => e
              my_logger.info("Exception in BT subscription creation "+ "Message -> "+e.message)
              my_logger.info("organization Name"+@current_organization.name.to_s)
              my_logger.info("organization ID"+@current_organization.id.to_s)
              my_logger.info("User ID"+@current_user.id.to_s)
              format.json { render json: e.message, status: :unprocessable_entity }
            end
            if result_plan.success?
                usersub = UserSubscription.create(:organization_id => @current_organization.id,:user_id => @current_user.id  ,:user_limit=>user_limit,:price=>params[:price], :subscription_id =>  Subscription.first.id ,:btsubscription_id=>result_plan.subscription.id,:btprofile_id=> result.customer.id,:cc_token=>result.customer.credit_cards.first.token,:payment_status=> result_plan.subscription.status,:is_updown=>'started',:subscription_start_date=>result_plan.subscription.billing_period_start_date,:next_billing_date=>result_plan.subscription.next_billing_date)
                format.json { head :no_content }
            else
              my_logger.info("Braintree Exception in BT subscription creation "+ "Message -> "+result_plan.message)
              my_logger.info("organization Name"+@current_organization.name.to_s)
              my_logger.info("organization ID"+@current_organization.id.to_s)
              my_logger.info("User ID"+@current_user.id.to_s)
              format.json { render json: result_plan.message, status: :unprocessable_entity }
            end
          else
            my_logger.info("Braintree Exception in BT profile creation "+ "Message -> "+result.message)
            my_logger.info("organization Name"+@current_organization.name.to_s)
            my_logger.info("organization ID"+@current_organization.id.to_s)
            my_logger.info("User ID"+@current_user.id.to_s)
            format.json { render json: result.message, status: :unprocessable_entity }
          end        
      #  end
    rescue => e
      puts "-----------------exception "
      p e.backtrace
      format.json { render json: e.message, status: :unprocessable_entity }
    end
   end
  end

  def update
    my_logger ||= Logger.new("#{Rails.root}/log/payment.log")
    my_logger.info("--------subscription update---"+ Time.now.to_s + "-----------")    
    respond_to do |format|
    begin
      #respond_to do |format|
      @u_subs = @current_organization.user_subscriptions.last
      if params[:user_limit].to_i > @u_subs.user_limit.to_i
          subscription_type = "up"
      elsif params[:user_limit].to_i < @u_subs.user_limit.to_i
          subscription_type = "down"      
      end
      if params[:user_limit].to_i == @u_subs.user_limit.to_i
         format.json { render json: "You are already in the same plan", status: :unprocessable_entity }     
      end
      begin 
         subscription = Braintree::Subscription.find(@u_subs.btsubscription_id)  
      rescue => e
         my_logger.info("BT Exception in BT profile find "+ "Message -> "+e.message)
         my_logger.info("organization Name"+@current_organization.name)
         my_logger.info("organization ID"+@current_organization.id)
         my_logger.info("User ID"+@current_user.id)   
         format.json { render json: e.message, status: :unprocessable_entity }                   
      end    
      if (subscription.status.downcase == 'active' || subscription.status.downcase == 'past due' || subscription.status.downcase == 'pending') && @u_subs.is_active
        puts "------------subscription is active"
        # sub_result = Braintree::Subscription.cancel(@u_subs.btsubscription_id)
        # if sub_result.success?  
        #   @u_subs.update_attributes :is_cancel => true, :cancel_date => Time.now, :is_active => false
        #   # Notification.subscription_cancel("Subscription cancelled due to upgrade").deliver
        # end
        begin 
          result_plan = Braintree::Subscription.update(@u_subs.btsubscription_id,
            :price => (params[:user_limit].to_i * 5)
          )
        rescue => e
          my_logger.info("Exception in BT subscription update "+ "Message -> "+e.message)
          my_logger.info("organization Name"+@current_organization.name.to_s)
          my_logger.info("organization ID"+@current_organization.id.to_s)
          my_logger.info("User ID"+@current_user.id.to_s)    
          format.json { render json: e.message, status: :unprocessable_entity }     
        end
        if result_plan.success?  
          @u_subs.update_attributes :is_active => false
          usersub = UserSubscription.create(:organization_id => @current_organization.id,:user_id => @current_user.id  ,:user_limit=>params[:user_limit],:price=>params[:price], :subscription_id =>  Subscription.first.id ,:btsubscription_id=>result_plan.subscription.id,:btprofile_id=> @u_subs.btprofile_id,:cc_token=>@u_subs.cc_token,:payment_status=> result_plan.subscription.status,:is_updown=>subscription_type,:subscription_start_date=>result_plan.subscription.billing_period_start_date,:next_billing_date=>result_plan.subscription.next_billing_date)   
          format.json { head :no_content }     
        else
          my_logger.info("BT Exception in BT subscription update "+ "Message -> "+result_plan.message)
          my_logger.info("organization Name"+@current_organization.name.to_s)
          my_logger.info("organization ID"+@current_organization.id.to_s)
          my_logger.info("User ID"+@current_user.id.to_s)
          format.json { render json: result_plan.message, status: :unprocessable_entity }
        end

      elsif subscription.status.downcase == 'canceled'        
        # begin 
        #   result = Braintree::Customer.find(@u_subs.btprofile_id)
        #   is_user = "present"
        
        # rescue #=> Braintree::NotFoundError
        #   is_user = "not_present"
        # end
        # p is_user
        #TODO finding last BT profile and update the oldrecord in vault rather creating new one
        begin 
          result = Braintree::Customer.create(
              :first_name => params[:card_holder_name],
              :last_name => '',
              :email => @current_user.email,
              :phone => '',
              :company => @current_organization.name,
              :credit_card => {
                :number => params[:card_number],
                :cardholder_name => params[:card_holder_name],
                :expiration_date => "#{params[:exp_month]}/#{params[:exp_year]}",
                :cvv => params[:CVV2],
                :options => {
                  :verify_card => true
                },
                :billing_address => {
                  :company => @current_organization.name,
                  :street_address => params[:street_address],
                  :locality => params[:city],
                  :region =>params[:state],
                  :postal_code => params[:zipcode],
                  :country_code_alpha2 => params[:country_code_alpha2]
                }         
              }
            )
        rescue => e
          my_logger.info("Exception in BT customer create "+ "Message -> "+e.message)
          my_logger.info("organization Name"+@current_organization.name)
          my_logger.info("organization ID"+@current_organization.id.to_s)
          my_logger.info("User ID"+@current_user.id.to_s)
          format.json { render json: e.message, status: :unprocessable_entity }
        end
        user_limit = params[:user_limit]
        if result.success?        
          if @current_organization.trial_expired?
               result_plan = Braintree::Subscription.create(
                      :payment_method_token => result.customer.credit_cards.first.token,
                      :plan_id => 'rr9r',
                      :price => params[:price]
               )
             
          else
               result_plan = Braintree::Subscription.create(
                      :payment_method_token => result.customer.credit_cards.first.token,
                      :plan_id => 'rr9r',
                      :price => params[:price],
                      :trial_duration => @current_organization.trail_days_left_in_days,
                      :trial_period => true,
                      :trial_duration_unit => 'day'
               )
             
          end
          if result_plan.success?
              usersub = UserSubscription.create(:organization_id => @current_organization.id,:user_id => @current_user.id  ,:user_limit=>user_limit,:price=>params[:price], :subscription_id =>  Subscription.first.id ,:btsubscription_id=>result_plan.subscription.id,:btprofile_id=> result.customer.id,:cc_token=>result.customer.credit_cards.first.token,:payment_status=> result_plan.subscription.status,:is_updown=>'started',:subscription_start_date=>result_plan.subscription.billing_period_start_date,:next_billing_date=>result_plan.subscription.next_billing_date)    
              format.json { head :no_content }        
          else
            my_logger.info("BT Exception in BT customer create "+ "Message -> "+result_plan.message)
            my_logger.info("organization Name"+@current_organization.name.to_s)
            my_logger.info("organization ID"+@current_organization.id.to_s)
            my_logger.info("User ID"+@current_user.id.to_s)
            format.json { render json: result_plan.message, status: :unprocessable_entity }
          end
        else
          my_logger.info("Braintree Exception in BT profile creation "+ "Message -> "+result.message)
          my_logger.info("organization Name"+@current_organization.name.to_s)
          my_logger.info("organization ID"+@current_organization.id.to_s)
          my_logger.info("User ID"+@current_user.id.to_s)
          format.json { render json: result.message, status: :unprocessable_entity }
        end
      #end         
     end
   rescue => e
      format.json { render json: e.message, status: :unprocessable_entity }
    end
   end
  end

  def cancel
    begin
      current_sub = @current_organization.user_subscriptions.active.first
       begin 
          subscription = Braintree::Subscription.find(current_sub.btsubscription_id)  
       rescue => e   
          my_logger.info("Braintree Exception in BT profile creation "+ "Message -> "+e.message)
          my_logger.info("organization Name"+@current_organization.name)
          my_logger.info("organization ID"+@current_organization.id.to_s)
          my_logger.info("User ID"+@current_user.id.to_s)                    
       end 
       if subscription.status == ('Active' || 'Past Due')
          result = Braintree::Subscription.cancel(current_sub.btsubscription_id)
          if result.success?     
             current_sub.update_attributes :is_cancel => true, :cancel_date => Time.now, :is_active => false, :payment_status => "Canceled"
             Notification.subscription_cancel("Subscription cancelled by user").deliver
             flash[:bosuccess] = "Subscription cancelled"        
          else
            my_logger.info("Braintree Exception in BT subscription cancel "+ "Message -> "+result.message)
            my_logger.info("organization Name"+@current_organization.name)
            my_logger.info("organization ID"+@current_organization.id.to_s)
            my_logger.info("User ID"+@current_user.id.to_s)    
            flash[:bodanger] = "Error during subscription cancel"
          end
       end     
     rescue => e
      flash[:bodanger] = "Error: #{e.message}"
     end
     redirect_to "/users/subscription"
  end


 def subscription
    @trans = @current_organization.user_subscriptions.order("created_at desc")
    @current_sub = @current_organization.user_subscriptions.active.first
    # unless @current_organization.trial_expires_on > Time.now.to_datetime
    #   trialp = false
    #   @current_sub = @current_organization.user_subscriptions.active.first
    #   @trans = @current_user.user_subscriptions.order("created_at desc")
    # else
    #    trialp = true
    # end
    # @trial_period = trialp 
 end

 def webhook
  my_logger ||= Logger.new("#{Rails.root}/log/bt_webhook.log")
  my_logger.info("--------webhook-------------at---"+ Time.now.to_s + "-----------")
  begin 
    bt_signature_param = params[:bt_signature]
    bt_payload_param = params[:bt_payload]
    webhook_notification = Braintree::WebhookNotification.parse(
        bt_signature_param, bt_payload_param
    )
    #wait till user subscription get updated
    sleep(10)
    #unless (Transaction.where("transaction_id =? and status = ?", webhook_notification.subscription.transactions.first.id,webhook_notification.subscription.status)).present?      
    if webhook_notification.subscription.id.present?
      user_sub = UserSubscription.where("btsubscription_id = ? and is_active = ?", webhook_notification.subscription.id, true).last      
      if user_sub.present?
          if webhook_notification.kind.present?
            if webhook_notification.subscription.balance >= 0.to_d
               begin 
                 user_trans = Transaction.create(:organization_id => user_sub.organization_id, :user_id => user_sub.user_id ,:amount => webhook_notification.subscription.transactions.first.amount, :balance => webhook_notification.subscription.balance, :btsubscription_id => webhook_notification.subscription.id, :next_billing_date => webhook_notification.subscription.next_billing_date, :plan_id => user_sub.subscription_id, :status => webhook_notification.subscription.status, :subscription_price => webhook_notification.subscription.price, :transaction_id => webhook_notification.subscription.transactions.first.id, :transaction_type => webhook_notification.kind, :ip => request.remote_ip, :user_subscription_id => user_sub.id)
                   begin 
                    user_sub.update_attributes(:subscription_start_date => webhook_notification.subscription.billing_period_start_date) 
                   rescue
                   end
               rescue => e
                  my_logger.info("Exception while inserting data to Transaction table "+ "Message -> "+e.message)
                  my_logger.info("Organization Name"+user_sub.organization.name)
                  my_logger.info("Organization ID"+user_sub.organization_id.to_s)
                  my_logger.info("Subscription ID"+webhook_notification.subscription.id.to_s)
                  my_logger.info("Transaction ID"+webhook_notification.subscription.transactions.first.id.to_s)    
                  my_logger.info("Transaction Type"+webhook_notification.kind.to_s)   
                  Notification.subscription_payment_error(e.backtrace.join("\n")).deliver
               end           
            end
            if webhook_notification.kind.to_s == "subscription_charged_successfully" 
               # Notification.subscription_payment_success(webhook_notification.kind).deliver
              if webhook_notification.subscription.balance >= 0.to_d
               ##logic to send invoice
               Notification.subscription_payment_notification("You have a new invoice from wus",webhook_notification.subscription.transactions.first.amount).deliver
              else
                # $usrSub1 = $this->UserSubscriptions->find('all',array('conditions'=>array('UserSubscriptions.company_id'=>$usrSub['UserSubscriptions']['company_id']),'order'=>'UserSubscriptions.id DESC','limit'=>'1,1'));
                # $subject = "Billing skipped for this month on Orangescrum";
                # if(($usrSub['UserSubscriptions']['subscription_id'])<$usrSub1[0]['UserSubscriptions']['subscription_id']){
                #   //$subject = "Plan downgrade transaction details from Orangescrum ";
                #   $ptext = " After plan downgrade your account holds a positive balance of ";
                # }elseif(($usrSub['UserSubscriptions']['subscription_id'])>$usrSub1[0]['UserSubscriptions']['subscription_id']){
                #   $ptext = " After plan upgradation you account holds a positive balance of ";
                #   //$subject = "Plan upgrade transaction details from Orangescrum ";
                # }else{
                #   $ptext = " After monthly subscription your account holds a positive balance of ";
                #   //$subject = "Monthly subscription payment details";
                # }
                Notification.subscription_payment_notification("Billing skipped for this month on WUS",webhook_notification.subscription.balance).deliver
              end
            elsif webhook_notification.kind == "subscription_charged_unsuccessfully"

               ##create table for event log 
               ##and store informations
               # $json_arr['company_id'] = $usrSub['UserSubscriptions']['company_id'];
               #  $json_arr['owner_name'] = $usr['Users']['name']." ".$usr['Users']['last_name'];
               #  $json_arr['email'] =  $usr['Users']['email'];
               #  $json_arr['price'] = $usrSub['UserSubscriptions']['price'];
               #  $json_arr['transaction_id'] = $webhookNotification->subscription->transactions[0]->id;
               #  $this->Postcase->eventLog($usrSub['UserSubscriptions']['company_id'],$usrSub['UserSubscriptions']['user_id'],$json_arr,32);                     

              begin 
                  subscription = Braintree::Subscription.find(webhook_notification.subscription.id)  
              rescue => e                     
                  my_logger.info("BT Exception BT subscription find "+ "Message -> "+e.message)
                  my_logger.info("Organization Name"+user_sub.organization.name)
                  my_logger.info("Organization ID"+user_sub.organization_id.to_s)
                  my_logger.info("Subscription ID"+webhook_notification.subscription.id.to_s)
                  my_logger.info("Transaction ID"+webhook_notification.subscription.transactions.first.id.to_s)    
                  my_logger.info("Transaction Type"+webhook_notification.kind.to_s) 
              end 
              if (subscription.status.downcase == 'active') || (subscription.status.downcase == 'past due') || (subscription.status.downcase =='pending')
                  begin 
                    result = Braintree::Subscription.cancel(webhook_notification.subscription.id)
                  rescue => e
                    my_logger.info("BT Exception BT subscription Cancel "+ "Message -> "+e.message)
                    my_logger.info("Organization Name"+user_sub.organization.name)
                    my_logger.info("Organization ID"+user_sub.organization_id.to_s)
                    my_logger.info("Subscription ID"+webhook_notification.subscription.id.to_s)
                    my_logger.info("Transaction ID"+webhook_notification.subscription.transactions.first.id.to_s)    
                    my_logger.info("Transaction Type"+webhook_notification.kind.to_s) 
                  end
                  if result.success?     
                     user_sub.update_attributes :is_cancel => true, :cancel_date => Time.now, :is_active => false, :is_cancel_payment_fail => true, :payment_status => "Canceled"
                     Notification.subscription_cancel("Subscription cancelled in due to payment failed").deliver
                  
                  else
                    my_logger.info("BT Exception BT subscription finc "+ "Message -> "+result.message)
                    my_logger.info("Organization Name"+user_sub.organization.name)
                    my_logger.info("Organization ID"+user_sub.organization_id.to_s)
                    my_logger.info("Subscription ID"+webhook_notification.subscription.id.to_s)
                    my_logger.info("Transaction ID"+webhook_notification.subscription.transactions.first.id.to_s)    
                    my_logger.info("Transaction Type"+webhook_notification.kind.to_s)                     
                  end
              end
            end
        end
      end
    end       
    #end
    render :text => "success"
  rescue => e
    my_logger.info("Exception"+e.backtrace.join("\n"))
    Notification.subscription_payment_error(e.backtrace.join("\n")).deliver
  end
 end

 def transactions
    @trans = @current_organization.transactions.by_success.order("created_at desc")
 end

 
 def check_trial_period_expiration
  Organization.where(:is_trial_expired=>false).where(:is_sub_active=>false).each do |o|
    if o.trial_expires_on.to_datetime < Time.now.to_datetime
       o.update_attributes :is_trial_expired => true 
       o.users.where(["admin_type not in (?)", [0,1]]).update_all is_active: false
       Notification.subscription_payment_notification("Trial period expired for Organization #{o.name}", 0).deliver
    end
  end
  #Notification.subscription_payment_notification("Subscription expired checl function run success", 0).deliver
  render :text => "success"
 end

def credit_card
  #@credit_card = @current_organization.credit_card.order("created_at desc")
  @current_sub = @current_organization.user_subscriptions.active.first
  begin 
    @creditcard = Braintree::CreditCard.find(@current_sub.cc_token) if @current_sub
  rescue
    @creditcard = nil
  end
end

def edit_credit_card
  @u_subs = @current_organization.user_subscriptions.last
  current_sub = @current_organization.user_subscriptions.active.first
  begin 
    @creditcard = Braintree::CreditCard.find(current_sub.cc_token) if current_sub
    begin 
      cc_country = @creditcard.present? && @creditcard.billing_address.present? ? @creditcard.billing_address.country_name : ""
      @cc_alpha_code = Country.where(name: cc_country).first.ccode
    rescue
      @cc_alpha_code = ""
    end
  rescue
    @creditcard = nil
  end
end

def update_credit_card
  respond_to do |format|
    current_sub = @current_organization.user_subscriptions.active.first
    puts "======================update_credit_card"
    p params
    p current_sub

    my_logger ||= Logger.new("#{Rails.root}/log/payment.log")
    my_logger.info("--------update_credit_card---"+ Time.now.to_s + "-----------")
    
    begin
        customer = Braintree::Customer.find(current_sub.btprofile_id)
    rescue => e
        my_logger.info("Exception in BT Customer find"+ "Message -> "+e.message)
        my_logger.info("organization Name"+@current_organization.name.to_s)
        my_logger.info("organization ID"+@current_organization.id.to_s)
        my_logger.info("User ID"+@current_user.id.to_s)
        format.json { render json: e.message, status: :unprocessable_entity }
    end 
    if customer.present?
      begin 
        result = Braintree::Customer.update(current_sub.btprofile_id,
                    :first_name => params[:card_holder_name],
                    :last_name => '',
                    :email => @current_user.email,
                    :phone => '',
                    :company => @current_organization.name,
                    :credit_card => {
                      :number => params[:card_number],
                      :cardholder_name => params[:card_holder_name],
                      :expiration_date => "#{params[:exp_month]}/#{params[:exp_year]}",
                      :cvv => params[:CVV2],
                      :options => {
                        :update_existing_token => current_sub.cc_token,
                        :verify_card => true
                      },
                      :billing_address => {
                        :company => @current_organization.name,
                        :street_address => params[:street_address],
                        :locality => params[:city],
                        :region =>params[:state],
                        :postal_code => params[:zipcode],
                        :country_code_alpha2 => params[:country_code_alpha2]
                      }         
                    }
                  )
        p result
      rescue => e
        my_logger.info("Exception in BT profile creation "+ "Message -> "+e.message)
        my_logger.info("organization Name"+@current_organization.name.to_s)
        my_logger.info("organization ID"+@current_organization.id.to_s)
        my_logger.info("User ID"+@current_user.id.to_s)
        format.json { render json: e.message, status: :unprocessable_entity }
      end

      if result.success?
        #Credit card information upgraded successfully!
        format.json { head :no_content }
      else
        # p result
        # my_logger.info("Exception in BT Customer update "+ "Message -> "+e.message)
        # my_logger.info("organization Name"+@current_organization.name.to_s)
        # my_logger.info("organization ID"+@current_organization.id.to_s)
        # my_logger.info("User ID"+@current_user.id.to_s)
        format.json { render json: e.message, status: :unprocessable_entity }
      end  
    else
      my_logger.info("Exception in BT Customer not find"+ "Message -> "+e.message)
      my_logger.info("organization Name"+@current_organization.name.to_s)
      my_logger.info("organization ID"+@current_organization.id.to_s)
      my_logger.info("User ID"+@current_user.id.to_s)
      format.json { render json: "Sorry!!! Invalid profile informations", status: :unprocessable_entity }
    end
  end
end  

def download_invoice
  @tran = @current_organization.transactions.where("invoice_id =?", params[:invoice_id]).first
  generate_invoice_pdf
  send_data @pd_invoice.render_pdf, :filename => "#{@tran.organization.name.gsub(' ','_')}_#{@tran.invoice_id}.pdf", :type => "application/pdf"
end

def generate_invoice_pdf
    Payday::Config.default.invoice_logo = "public/default_logo.png"
    Payday::Config.default.company_name = @tran.organization.name
    Payday::Config.default.company_details = "Address goes here"
    if @tran
      @pd_invoice = Payday::Invoice.new(:invoice_number => @tran.invoice_id, :bill_to => "test", :notes => "Notes", :paid_at => @tran.created_at.strftime("%m-%d-%Y"), :tax_rate => "")
      @pd_invoice.line_items << Payday::LineItem.new(:price => @tran.amount, :quantity => 1, :description => "test line items")
    end   
  end

  def get_invoice_email
    @tran = @current_organization.transactions.where("id =?", params[:id]).first
    render :partial => "send_invoice_email"
  end
private 
  def assign_user
     @user = current_user     
  end


end
