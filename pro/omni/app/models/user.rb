class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :invitable
  
  has_many :assets, :foreign_key => "created_by", :class_name => "Asset"


  def is_verified
  	confirmed_at.present? ? "Yes" : "No"
  end

  def is_invited
  	invitation_created_at.present? ? "Yes" : "No"
  end

  def accepted_invitation
  	invitation_accepted_at.present? ? "Yes" : "No"
  end

end
