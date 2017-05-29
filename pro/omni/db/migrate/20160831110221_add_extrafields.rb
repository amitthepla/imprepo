class AddExtrafields < ActiveRecord::Migration
  def change
  	add_column :users, :is_blocked, :boolean, :default => false
  	add_column :contents, :created_by, :integer
  end
end
