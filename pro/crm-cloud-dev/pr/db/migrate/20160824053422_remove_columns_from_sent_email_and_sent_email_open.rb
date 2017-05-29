class RemoveColumnsFromSentEmailAndSentEmailOpen < ActiveRecord::Migration
 def change
  	remove_column :sent_emails, :obj_id
  	remove_column :sent_emails, :obj_type

  	remove_column :sent_email_opens, :obj_id
  	remove_column :sent_email_opens, :obj_type
  	remove_column :sent_email_opens, :mail_letter_id
  	add_column :sent_email_opens, :activity_id, :integer

  end
end
