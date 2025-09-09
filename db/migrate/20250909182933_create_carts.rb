class CreateCarts < ActiveRecord::Migration[8.0]
  def change
    create_table :carts do |t|
      t.string :session_id, limit: 255
      
      t.timestamps
    end
    
    add_index :carts, :session_id, unique: true
  end
end
