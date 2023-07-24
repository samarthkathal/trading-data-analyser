class CreateInstrumentsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :instruments, id: false, primary_key: :inst_id do |t|
      t.string :type, null: false
      t.string :name, null: false
      t.string :inst_id, null: false

      t.timestamps
    end
  end
end
