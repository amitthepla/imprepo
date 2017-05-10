class Invoice < ActiveRecord::Base  
  attr_accessible :cc_mail_id, :contact_id, :contact_type, :currency, :due_date, :invoice_no, :notes, :status, :terms_and_condition, :transaction_date, :user_id, :organization_id, :deal_id, :logo_url, :company_name, :company_address, :tax, :invoice_items_attributes, :invoice_items
  has_one :image, :as => :imagable, :dependent => :destroy
  has_many :invoice_items
  belongs_to :user
  belongs_to :organization
  belongs_to :deal
  accepts_nested_attributes_for :invoice_items, reject_if: proc { |attributes| attributes['qty'].blank? && attributes['rate'].blank? }, :allow_destroy => true
end
