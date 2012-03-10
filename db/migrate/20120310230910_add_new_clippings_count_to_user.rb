class AddNewClippingsCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :new_clippings_count, :integer
  end
end
