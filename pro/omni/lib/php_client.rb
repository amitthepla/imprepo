require 'rest-client'
module PHPClient
  def self.fetch_image_urls(host_url, content)
    response = RestClient.post(host_url, {excel_path: content.attachment.path, doc_id: content.id})
    response.code == 200 ? store_url_to_db(JSON.parse(response.body)['info'], content) : nil
  end

  def self.store_url_to_db(data, content)
    images_hash = {}
    data.each { |item| images_hash.merge!(item) }
    content.update_attributes({images_url: images_hash.to_json})
  end
end
