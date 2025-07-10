class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true, index: false
      t.references :food, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.integer :price, null: false

      t.timestamps
      t.index %i[order_id food_id], unique: true
    end
  end
end
