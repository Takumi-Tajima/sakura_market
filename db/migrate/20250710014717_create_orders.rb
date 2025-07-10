class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :total_amount, null: false
      t.integer :subtotal, null: false
      t.integer :shipping_fee, null: false
      t.integer :cash_on_delivery_fee, null: false
      t.integer :tax_amount, null: false
      t.date :delivery_on, null: false
      t.string :delivery_time_slot, null: false
      t.string :delivery_name, null: false
      t.text :delivery_address, null: false
      t.datetime :ordered_at, null: false

      t.timestamps
    end
  end
end
