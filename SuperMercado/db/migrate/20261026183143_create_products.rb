class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price, precision: 10, scale: 2
      t.integer :inventary, null: false, default: 0
      t.string :barcode
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
