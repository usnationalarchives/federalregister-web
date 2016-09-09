class ChangeConfirmationTokenLength < ActiveRecord::Migration
  def up
    change_column :users, :confirmation_token, :string, limit: 20
    change_column :users, :email, :string, limit: 120
    change_column :users, :reset_password_token, :string, limit: 20
  end

  def down
  end
end
