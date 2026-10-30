class CreateItemSales < ActiveRecord::Migration[8.1]
  def change
    create_table :item_sales do |t|
      t.references :sale, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :unit_prince, precision: 10, scale: 2

      t.timestamps
    end
  end
end
