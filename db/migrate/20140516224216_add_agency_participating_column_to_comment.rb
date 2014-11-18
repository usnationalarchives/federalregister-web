class AddAgencyParticipatingColumnToComment < ActiveRecord::Migration
  def change
    add_column :comments, :agency_participating, :boolean

    add_index :comments, :agency_participating
    add_index :comments, :comment_publication_notification
    add_index :comments, :document_number
    add_index :comments, :user_id
    add_index :comments, :comment_tracking_number
  end
end
