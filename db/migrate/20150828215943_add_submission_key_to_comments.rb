class AddSubmissionKeyToComments < ActiveRecord::Migration
  def change
    add_column :comments, :submission_key, :string
  end
end
