class Business::LeadPhoto
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  embedded_in :lead, class_name: 'Business::Lead'

  has_mongoid_attached_file :photo,
                            :source_file_options => { :all=>'-auto-orient' },
                            :styles => {large: '650x650>', medium: '300x300>', thumb: '100x100>', small_thumb: '20x20>'},
                            :convert_options => {:all => '-background white -flatten +matte'},
                            :path => '/lead_photos/:id/:styles_:basename.:extension',
                            :url => ':s3_domain_url',
                            # :s3_protocol => :https,
                            :s3_headers => {'Cache-Control' => 'max-age=315576000', 'Expires' => 1.year.from_now.httpdate }

  validates_attachment :photo, content_type: {
      content_type: %w(image/jpg image/jpeg image/png image/bmp image/gif),
      message: '^Upload image with extension .bmp, .gif, .jpg, .png only.'},
                       size: {:in => 0..10.megabytes, :message => '^Image must be less than 10 megabytes in size'}
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\Z/

end
