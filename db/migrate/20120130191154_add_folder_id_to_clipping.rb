class AddFolderIdToClipping < ActiveRecord::Migration
  def change
    add_column :clippings, :folder_id, :integer
  end
end
