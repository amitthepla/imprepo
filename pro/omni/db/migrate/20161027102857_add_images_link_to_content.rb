class AddImagesLinkToContent < ActiveRecord::Migration
  def change
    change_table :contents do |t|
      t.text :images_url
    end
  end
end
