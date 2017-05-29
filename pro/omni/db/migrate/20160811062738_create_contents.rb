class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.text :content
      t.boolean :is_downloaded, :default => false

      t.timestamps
    end
  end
end
