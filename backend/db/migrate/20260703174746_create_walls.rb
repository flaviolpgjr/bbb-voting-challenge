class CreateWalls < ActiveRecord::Migration[8.1]
  def change
    create_table :walls do |t|
      t.string :name, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.boolean :active, null: false, default: false

      t.timestamps
    end

    add_index :walls, :active
  end
end
