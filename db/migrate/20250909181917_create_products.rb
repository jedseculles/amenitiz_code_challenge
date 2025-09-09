class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :code, null: false, limit: 10
      t.string :name, null: false
      t.decimal :base_price, precision: 10, scale: 2, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :products, :code, unique: true
    add_index :products, :active
  end
end
