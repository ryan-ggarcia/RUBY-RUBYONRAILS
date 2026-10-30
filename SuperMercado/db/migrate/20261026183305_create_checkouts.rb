class CreateCheckouts < ActiveRecord::Migration[8.1]
  def change
    create_table :checkouts do |t|
      t.string :name
      t.boolean :open, null: false, default: true

      t.timestamps
    end
  end
end
