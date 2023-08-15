class CreateTradersTable < ActiveRecord::Migration[7.0]
  def change
    create_table :traders, id: false, primary_key: :unique_name do |t|
      t.string :unique_name, null: false
      t.index :unique_name, unique: true

      t.string :name, null: false
      t.decimal :aum
      t.decimal :pnl
      t.decimal :win_ratio
      t.decimal :yield_ratio

      t.datetime :last_scrapped_at
      t.timestamps
    end
  end
end
