class CommunityPlugin < ActiveRecord::Base
  has_many :plugin_transactions
  attr_accessible :description, :is_active, :name, :price, :unique_id, :is_plugin

  after_create :set_unique_id
  
  #unique ID is generated to access the checkout page
  #from outside
  def set_unique_id
    self.update_column(:unique_id, Digest::MD5.hexdigest(self.id.to_s+Time.now.to_s))
  end
end
