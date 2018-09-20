class RemoveOldColumnsFromSubscriptions < ActiveRecord::Migration
  def up
    remove_column :subscriptions, :email
    remove_column :subscriptions, :confirmed_at
  end

  def down
  end
end
