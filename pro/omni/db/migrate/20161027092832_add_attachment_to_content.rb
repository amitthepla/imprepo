class AddAttachmentToContent < ActiveRecord::Migration
  def change
    change_table :contents do |t|
      t.attachment :attachment
    end
  end
end
