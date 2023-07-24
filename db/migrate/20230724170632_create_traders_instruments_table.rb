class CreateTradersInstrumentsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :trader_instruments do |t|
      t.string :trader_id, null: false
      t.string :instrument_id, null: false
      t.timestamps
    end

    add_foreign_key :trader_instruments, :instruments, column: 'instrument_id', primary_key: 'instrument_id'
    add_foreign_key :trader_instruments, :traders, column: 'trader_id', primary_key: 'unique_name'
  end
end
