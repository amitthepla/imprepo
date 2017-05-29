class Plugin < ActiveRecord::Base
  attr_accessible :description, :is_active, :title
  has_many :user_plugins
  has_many :users, :through => :user_plugins
end
