class AddAgencyNameToComments < ActiveRecord::Migration
  def change
    add_column :comments, :agency_name, :string
  end
end
