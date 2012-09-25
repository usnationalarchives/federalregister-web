class CreateCommentAttachments < ActiveRecord::Migration
  def up
    create_table :comment_attachments do |t|
      t.string  :token
      t.string  :attachment
      t.string  :attachment_md5
      t.string  :salt
      t.string  :iv
      t.integer :file_size
      t.string  :content_type
      t.string  :original_file_name
      t.timestamps
    end
    add_index :comment_attachments, :created_at
  end

  def down
    drop_table :comment_attachments
  end
end
