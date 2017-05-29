class Asset < ActiveRecord::Base
	has_attached_file :file,:storage => :s3,
	                      :s3_credentials => S3_CREDENTIALS,
	                      :styles => { medium: "300x300>", icon: "30x30>" },
	                      :path => "/assets/:id/:style.:extension",
						  :url => "/assets/:id/:style.:extension"
	validates_attachment_content_type :file, content_type: /\Aimage\/.*\z/

	belongs_to :user, :foreign_key => "created_by", :class_name => "User"

end
