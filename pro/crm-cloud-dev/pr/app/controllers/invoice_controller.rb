require 'net/http'
require 'open-uri'
#require 'FileUtils'
class InvoiceController < ApplicationController
	before_filter :authenticate_admin
	def test
		Payday::Config.default.invoice_logo = "public/image/wakeup-salelogo.png"
		Payday::Config.default.company_name = "WakeUpSales"
		Payday::Config.default.company_details = "10 This Way\nManhattan, NY 10001\n800-111-2222\nawesome@awesomecorp.com"
		invoice = Payday::Invoice.new(:invoice_number => 12)
		invoice.line_items << Payday::LineItem.new(:price => 20, :quantity => 5, :description => "Pants")
		invoice.line_items << Payday::LineItem.new(:price => 10, :quantity => 3, :description => "Shirts")
		invoice.line_items << Payday::LineItem.new(:price => 5, :quantity => 200, :description => "Hats")
		send_data invoice.render_pdf, :filename => "Invoice #12.pdf", :type => "application/pdf", :disposition => "inline"
		#respond_to do |format|
		#  format.html
		#  format.pdf do
		#    send_data invoice.render_pdf, :filename => "Invoice #12.pdf", :type => "application/pdf", :disposition => "inline"
		#  end
		#end
	end
	def manage_invoice
		@invoices = @current_organization.invoices.order("id DESC")
		@title = "WakeUpSales | Free CRM Tool |Manage Invoice"
    	@description = "At WakeUpSales the free crm tool, registered user can manage invoices as per their requirement."
	end
	def index
		@pre_invoice = @current_organization.invoices.last
		@invoice = @current_organization.invoices.new
		@invoice_items = @invoice.invoice_items.build
		@title = "WakeUpSales | Free CRM Tool |Manage Invoice"
    	@description = "At WakeUpSales the free crm tool, registered user can manage invoices as per their requirement."
	end
	def create_invoice
		if params[:invoice][:contact_id].present?	
			p params			
			if params[:invoice][:contact_type] == "IndividualContact"
				@contact = @current_organization.individual_contacts.find_by_id(params[:invoice][:contact_id])
		    #else
		    #	@contact = CompanyContact.find_by_id(params[:invoice][:contact_id])
		    end
			@contact_id = @contact.id
			@invoice = @current_organization.invoices.create(user_id: current_user.id, contact_id: @contact_id, contact_type: params[:invoice][:contact_type], currency: params[:invoice][:currency], invoice_no: params[:invoice][:invoice_no], due_date: params[:invoice][:due_date], cc_mail_id: params[:invoice][:cc_mail_id], status: "Send", notes: params[:invoice][:notes], terms_and_condition: params[:invoice][:terms_and_condition], transaction_date: Time.new, :company_name => params[:invoice][:company_name], :deal_id => params[:invoice][:deal_id], :tax => params[:invoice][:tax], :company_address => params[:invoice][:company_address], :tax => params[:invoice][:tax])

			if params[:invoice][:image].present?
				@invoice.image = Image.create!( :organization => @current_organization, :imagable => @invoice, :image => params[:invoice][:image] )
		  		url = @invoice.image.image.url(:small)
		  	else
		  		if (pre_invoice = @current_organization.invoices).present? && (last_invoice_logo = pre_invoice.where("logo_url is NOT NULL and logo_url != ''").last).present?
		  			url = last_invoice_logo.logo_url
		  		else
		  			url = nil
		  		end
		  	end
		  	@invoice.update_column(:logo_url, url)

			if @invoice
				if @invoice.logo_url.present?
					download = open(url)
					IO.copy_stream(download, "public/logo_#{@invoice.id}.png")
					logo_path = "public/logo_#{@invoice.id}.png"
				end
				if logo_path.present?
					Payday::Config.default.invoice_logo = logo_path
				else
					Payday::Config.default.invoice_logo = "public/default_logo.png"
				end
				Payday::Config.default.company_name = params[:invoice][:company_name]
				Payday::Config.default.company_details = params[:invoice][:company_address]
				@invoice_items=[]
				params[:invoice][:invoice_items_attributes].each do |t|
					@invoice_items << @invoice.invoice_items.create(:amount => t[1]["amount"],:qty => t[1]["qty"],:rate => t[1]["rate"],:description => t[1]["description"])
				end
				# @invoice_item = @invoice.invoice_items.create(description: params[:description], amount: params[:amount])
				pd_invoice = Payday::Invoice.new(:invoice_number => @invoice.invoice_no, :bill_to => @contact.full_name + "\n" + @contact.email, :notes => params[:invoice][:notes], :tax_rate => params[:invoice][:tax].present? ? ("%.3f" % (params[:invoice][:tax].to_f / 100.0)) : "")
				@invoice_items.each do |item|
					pd_invoice.line_items << Payday::LineItem.new(:price => item.rate, :quantity => item.qty, :description => item.description)
				end
			end

			Notification.send_invoice_email(@contact.email,params[:invoice][:cc_mail_id], @current_organization.name, @invoice,@invoice_items,"",pd_invoice).deliver
			File.delete(logo_path) if logo_path.present? && File.exist?(logo_path)
			flash[:bosuccess] = "Invoice has been created successfully."
			redirect_to "/manage_invoice"
		else
			flash[:bowarning] = "Bill to address is incorrect! Make sure to select address from auto suggest."
			redirect_to "/invoice/create"
		end
	end


	def resend_invoice
		@invoice = @current_organization.invoices.find_by_id(params[:id])		
		@invoice.status = "Resend"
		@invoice.save
		generate_invoice_company
		# if @invoice
		# 	pd_invoice = Payday::Invoice.new(:invoice_number => @invoice.invoice_no, :bill_to => @contact.full_name + "\n" + @contact.email, :notes => @invoice.notes)
		# 	#pd_invoice.line_items << Payday::LineItem.new(:price => @invoice_item.amount, :quantity => 1, :description => @invoice_item.description)
		# 	@invoice_items.each do |item|
		# 		pd_invoice.line_items << Payday::LineItem.new(:price => item.rate, :quantity => item.qty, :description => item.description)
		# 	end
		# end

		Notification.send_invoice_email(@contact.email,"", @current_organization.name, @invoice,@invoice_items,"Reminder for your Payment", @pd_invoice).deliver
		File.delete(@logo_path) if @logo_path.present? && File.exist?(@logo_path)
		flash[:notice] = "Invoice has been re-send successfully."
		redirect_to "/manage_invoice"
	end


	def paid_invoice
		@invoice = @current_organization.invoices.find_by_id(params[:id])		
		@invoice.update_attribute :status, "Paid"
		@invoice.save
		generate_invoice_company

		# if @invoice
		# 	pd_invoice = Payday::Invoice.new(:invoice_number => @invoice.invoice_no, :bill_to => @contact.full_name + "\n" + @contact.email, :notes => @invoice.notes, :paid_at => @invoice.updated_at.strftime("%m-%d-%Y"))
		# 	#pd_invoice.line_items << Payday::LineItem.new(:price => @invoice_item.amount, :quantity => 1, :description => @invoice_item.description)
		# 	@invoice_items.each do |item|
		# 		pd_invoice.line_items << Payday::LineItem.new(:price => item.rate, :quantity => item.qty, :description => item.description)
		# 	end
		# end

		Notification.send_invoice_paid_email(@contact.email, @current_organization.name, @invoice, @invoice_items,@pd_invoice).deliver
		File.delete(@logo_path) if @logo_path.present? && File.exist?(@logo_path)
		flash[:notice] = "Status changed to paid."
		redirect_to "/manage_invoice"
	end


	def cancel_invoice
		@invoice = @current_organization.invoices.find_by_id(params[:id])
		@invoice_items = @invoice.invoice_items
		@contact = @current_organization.individual_contacts.find_by_id(@invoice.contact_id)
		@invoice.status = "Cancelled"
		@invoice.save
		Notification.send_invoice_cancel_email(@contact.email, @current_organization.name, @invoice, @invoice_items).deliver
		flash[:notice] = "Invoice has been Cancelled."
		redirect_to "/manage_invoice"
	end
	def get_bill_to_details
		@cont_type = params[:cont_type]
		@cont_id = params[:cont_id]
		@contact = @current_organization.individual_contacts.where("id=?",@cont_id).first
		@deals=[]
	    @contact.deals_contacts.order("id desc").each do |dc|
	      @deals << dc.deal if dc.present?
	    end
		render :partial=> "invoice/show_bill_to_details"
	end
	def download_invoice
		@invoice = @current_organization.invoices.find_by_id(params[:id])		
		generate_invoice_company
		
		#path_to_file = "#{Rails.root}/public/invoices/pd_invoice_#{@invoice.id}.pdf"
		#pd_invoice.render_pdf_to_file(path_to_file)		
		
		#send_data (path_to_file), :type => 'application/pdf'
		send_data @pd_invoice.render_pdf, :filename => "#{@invoice.company_name.gsub(' ','_')}_#{@invoice.invoice_no}.pdf", :type => "application/pdf"
		File.delete(@logo_path) if @logo_path.present? && File.exist?(@logo_path)
	end
	def generate_invoice_company
		@invoice_items = @invoice.invoice_items
		@contact = @current_organization.individual_contacts.find_by_id(@invoice.contact_id)
		
		
		if (url=@invoice.logo_url).present?
			download = open(url)
			IO.copy_stream(download, "public/logo_#{@invoice.id}.png")
			@logo_path = "public/logo_#{@invoice.id}.png"
		end
		if @logo_path.present?
			Payday::Config.default.invoice_logo = @logo_path
		else
			Payday::Config.default.invoice_logo = "public/default_logo.png"
		end
		Payday::Config.default.company_name = @invoice.company_name
		Payday::Config.default.company_details = @invoice.company_address
		if @invoice
			@pd_invoice = Payday::Invoice.new(:invoice_number => @invoice.invoice_no, :bill_to => @contact.full_name + "\n" + @contact.email, :notes => @invoice.notes, :paid_at => @invoice.status.downcase == "paid" ? @invoice.updated_at.strftime("%m-%d-%Y") : nil, :tax_rate => @invoice.tax.present? ? ("%.3f" % (@invoice.tax.to_f / 100.0)) : "")
			#pd_invoice.line_items << Payday::LineItem.new(:price => @invoice_item.amount, :quantity => 1, :description => @invoice_item.description)
			@invoice_items.each do |item|
				@pd_invoice.line_items << Payday::LineItem.new(:price => item.rate, :quantity => item.qty, :description => item.description)
			end
		end		
	end

	def check_unique_invoice
		render json: @current_organization.invoices.where("invoice_no=?",params[:invoice_no]).first.present?
	end
end
