class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.text :plan_id
      t.integer :user_limit
      t.integer :storage_limit
      t.boolean :is_active, :default => true
      t.float :price
      t.integer :free_trial_days
      t.references :organization

      t.timestamps
    end
    add_index :subscriptions, :organization_id
  end
end
