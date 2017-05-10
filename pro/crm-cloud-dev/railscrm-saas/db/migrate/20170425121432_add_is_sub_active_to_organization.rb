class AddIsSubActiveToOrganization < ActiveRecord::Migration
  def change
  	remove_column :organizations, :is_sub_active
    add_column :organizations, :is_sub_active, :boolean, :default => false
  end
end
