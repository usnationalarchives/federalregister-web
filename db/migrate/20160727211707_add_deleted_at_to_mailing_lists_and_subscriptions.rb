class AddDeletedAtToMailingListsAndSubscriptions < ActiveRecord::Migration
  def change
    add_column :mailing_lists, :deleted_at, :timestamp
    add_column :subscriptions, :deleted_at, :timestamp

    add_index :mailing_lists, :deleted_at
    add_index :subscriptions, :deleted_at
  end
end
