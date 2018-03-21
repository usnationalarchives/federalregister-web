class RemoveActiveSubscriptionsCountFromMailingLists < ActiveRecord::Migration
  def up
    remove_column :mailing_lists, :active_subscriptions_count
  end
end
