class AddLastDocumentsDeliveredHashToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :last_documents_delivered_hash, :string
    add_index :subscriptions, [:mailing_list_id, :last_documents_delivered_hash], name: "mailing_list_documents"
  end
end
