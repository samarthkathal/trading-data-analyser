class CreateInstrumentsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :instruments, id: false, primary_key: :instrument_id do |t|
      t.string :instrument_id, null: false
      t.index :instrument_id, unique: true

      t.string :name, null: false
      t.decimal :contract_multiplier
      t.string :contract_type
      t.decimal :contract_value
      t.string :contract_currency
      t.string :settle_currency

      t.timestamps
    end
  end
end
