class CreateHistoricalPositionsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :historical_positions, id: false, primary_key: :unique_id do |t|
      t.bigint :unique_id, null: false
      t.string :trader_id, null: false
      t.string :instrument_id, null: false

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

    add_index :historical_positions, :unique_id, unique: true
    add_foreign_key :historical_positions, :instruments, column: "instrument_id", primary_key: "instrument_id"
    add_foreign_key :historical_positions, :traders, column: "trader_id", primary_key: "unique_name"
  end
end
