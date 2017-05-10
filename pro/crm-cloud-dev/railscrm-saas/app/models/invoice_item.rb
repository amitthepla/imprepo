class InvoiceItem < ActiveRecord::Base
  attr_accessible :amount, :description, :invoice_id, :qty, :rate
  belongs_to :invoice
end
