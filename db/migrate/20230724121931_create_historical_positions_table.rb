class CreateHistoricalPositionsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :historical_positions do |t|
      t.references :trader, null: false, foreign_key: true
      t.references :instrument, null: false, foreign_key: true

      t.integer :leverage, null: false
      t.decimal :margin, null: false
      t.decimal :pnl, null: false

      t.string :margin_mode, null: false
      t.decimal :open_avg_price, null: false
      t.decimal :close_avg_price, null: false
      t.decimal :side, null: false
      t.datetime :open_time, null: false
      t.datetime :close_time, null: false

      t.timestamps
    end
  end
end
