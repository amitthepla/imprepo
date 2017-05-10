class AddIsCancelPaymentFailToUserSubscription < ActiveRecord::Migration
  def change
    add_column :user_subscriptions, :is_cancel_payment_fail, :boolean, :default => false
  end
end
