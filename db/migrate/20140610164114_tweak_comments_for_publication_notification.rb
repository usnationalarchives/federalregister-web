class TweakCommentsForPublicationNotification < ActiveRecord::Migration
  def up
    add_column :comments, :comment_document_number, :string
    rename_column :comments, :comment_published_at, :checked_comment_publication_at
  end

  def down
    rename_column :comments, :checked_comment_publication_at, :comment_published_at
    remove_column :comments, :comment_document_number
  end
end
