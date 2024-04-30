class CreateStatistics < ActiveRecord::Migration[6.1]
  def change
    create_table :statistics do |t|
      t.string :statistic_type
      t.date :date
      t.integer :count
      t.index [:statistic_type, :date]
      t.timestamps
    end
  end
end
