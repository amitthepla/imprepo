class ChangeContentColumn < ActiveRecord::Migration
  def change
  	rename_column :contents, :is_downloaded, :is_ppt
  end
end
