class Content < ActiveRecord::Base

  has_attached_file :attachment,
                    :storage => :s3,
                    :s3_credentials => S3_CREDENTIALS,
                    :path => '/sheets/:id/:basename.:extension',
                    :url => '/sheets/:id/:basename.:extension'

  validates_attachment_content_type :attachment, content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', message: ' Only EXCEL files(.xlsx) are allowed.'

  def self.to_csv
    CSV.generate do |csv|
      # csv << ["Content"] ## Header values of CSV
      all.each do |cnt|
        csv << [cnt.content] ##Row values of CSV
      end
    end
  end

  def replace_text_with_url
    return self.content unless self.images_url.present?
    images_data = JSON.parse(self.images_url)
    doc_content = self.content.split(/(image\d+)/i)
    doc_content.each_with_index do |value, index|
      if value.match(/(image\d+)/i)
        doc_content[index] = images_data[value] ?  " #{images_data[value]} " : value
      end
    end
    doc_content.join
  end

end
