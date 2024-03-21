class AddTokenIndexToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_index :subscriptions, :token
  end
end
