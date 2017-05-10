class UserPlugin < ActiveRecord::Base
  belongs_to :user
  belongs_to :plugin
  # attr_accessible :title, :body
end
