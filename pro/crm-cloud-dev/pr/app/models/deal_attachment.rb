class DealAttachment < ActiveRecord::Base
  # attr_accessible :attachment
  Paperclip.interpolates :organization_id do |attachment, style|
    attachment.instance.organization_id
  end
  has_attached_file :attachment,
                    :storage => :s3,
                    :s3_credentials => S3_CREDENTIALS,
                    :path => '/:organization_id/deal_attachment/:id/:basename.:extension',
                    :url => '/:organization_id/deal_attachment/:id/:basename.:extension',
                    :s3_headers => {'Cache-Control' => 'max-age=315576000', 'Expires' => 1.years.from_now.httpdate }
  validates_attachment :attachment, size: {:in => 0..10.megabytes, :message => '^Uploades file must be less than 10MB in size'}
  validates_attachment_content_type :attachment, content_type: /.+\/.*\Z/

  belongs_to :deal
  belongs_to :organization
end