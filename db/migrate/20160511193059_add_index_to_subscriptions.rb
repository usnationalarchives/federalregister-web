class AddIndexToSubscriptions < ActiveRecord::Migration
  def change
    add_index :subscriptions, :email
  end
end
