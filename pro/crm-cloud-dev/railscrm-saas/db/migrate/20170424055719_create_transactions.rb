class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.text :btsubscription_id
      t.text :transaction_id
      t.text :plan_id
      t.string :status
      t.float :subscription_price
      t.float :amount
      t.float :balance
      t.datetime :next_billing_date
      t.text :transaction_type
      t.integer :invoice_id
      t.string :ip
      t.references :organization
      t.references :user
      t.references :user_subscription

      t.timestamps
    end
    add_index :transactions, :organization_id
    add_index :transactions, :user_id
    add_index :transactions, :user_subscription_id
  end
end
