class CreateSales < ActiveRecord::Migration[8.1]
  def change
    create_table :sales do |t|
      t.references :checkout, null: false, foreign_key: true
      t.decimal :total, precision: 10, scale: 2, default: 0
      t.string :status, null: false, default: "open"
      t.datetime :Completed_in

      t.timestamps
    end
  end
end
