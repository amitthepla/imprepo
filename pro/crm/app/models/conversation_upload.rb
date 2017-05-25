class ConversationUpload
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  has_mongoid_attached_file :attachment,
                            :path => '/chat_uploads/:id/:basename.:extension',
                            :url => ':s3_domain_url',
                            :s3_headers => {'Cache-Control' => 'max-age=315576000', 'Expires' => 1.year.from_now.httpdate}

  validates_attachment :attachment, size: {:in => 0..10.megabytes, :message => '^Uploades file must be less than 10MB in size'}
  validates_attachment_content_type :attachment, content_type: /.+\/.*\Z/

  belongs_to :conversation_reply

end
