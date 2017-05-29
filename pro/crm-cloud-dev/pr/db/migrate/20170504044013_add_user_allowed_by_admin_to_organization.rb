class AddUserAllowedByAdminToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :user_allowed_by_admin, :integer, :default => 0
    User.where(["admin_type not in (?)", [0,1]]).update_all is_active: false
  end
end
