class CreateFoods < ActiveRecord::Migration[8.0]
  def change
    create_table :foods do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.integer :price, null: false
      t.boolean :published, null: false, default: false
      t.integer :position

      t.timestamps
    end
  end
end
