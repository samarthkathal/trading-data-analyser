class AddColumnAndIndexToSpeedUpScrapping < ActiveRecord::Migration[7.0]
  def change
    add_column :traders, :last_scrapped_at, :datetime
    add_index :historical_positions, :unique_id, unique: true
  end
end
