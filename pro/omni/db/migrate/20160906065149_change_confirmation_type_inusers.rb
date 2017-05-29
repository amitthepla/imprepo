class ChangeConfirmationTypeInusers < ActiveRecord::Migration
  def change
  	remove_column :users, :confirmation_token
  	remove_column :users, :confirmed_at
  	remove_column :users, :confirmation_sent_at
  	remove_column :users, :unconfirmed_email

  	add_column :users, :confirmation_token, :string
  	add_column :users, :confirmed_at, :datetime
  	add_column :users, :confirmation_sent_at, :datetime
  	add_column :users, :unconfirmed_email, :string

  end
end
