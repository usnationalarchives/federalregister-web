class CreateComments < ActiveRecord::Migration
  def up
    create_table :comments do |t|
      t.integer  :user_id
      t.string   :document_number
      t.string   :comment_tracking_number
      t.datetime :created_at

      t.boolean  :comment_publication_notification
      t.datetime :comment_published_at

      t.boolean  :followup_document_notification
      t.string   :followup_document_number
    end
  end

  def down
    drop_table :comments
  end
end
