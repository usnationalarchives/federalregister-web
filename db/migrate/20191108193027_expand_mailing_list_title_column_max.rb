class ExpandMailingListTitleColumnMax < ActiveRecord::Migration[5.2]
  def change
    change_column :mailing_lists, :title, :string, limit: 1000
  end
end
