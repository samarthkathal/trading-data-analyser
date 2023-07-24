class CreateTradersInstrumentsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :traders_instruments do |t|
      t.references :trader, null: false, foreign_key: true
      t.references :instrument, null: false, foreign_key: true
      t.timestamps
    end
  end
end
