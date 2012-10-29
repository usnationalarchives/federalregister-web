class AddEncryptedCommentDataToComments < ActiveRecord::Migration
  def change
    add_column :comments, :salt, :string
    add_column :comments, :iv, :string
    add_column :comments, :encrypted_comment_data, :binary
  end
end
