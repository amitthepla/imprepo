class AddConfirmation < ActiveRecord::Migration
  def change
  	add_column :users, :confirmation_token, :text
  	add_column :users, :confirmed_at, :text
  	add_column :users, :confirmation_sent_at, :text
  	add_column :users, :unconfirmed_email, :text
    # add_index :users, :confirmation_token,   unique: true
  end
end
