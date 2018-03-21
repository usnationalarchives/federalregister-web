class AddMailingListIdAndDeletedAtIndexToSubscriptions < ActiveRecord::Migration
  def change
    add_index(:subscriptions, [:mailing_list_id, :deleted_at])
  end
end
