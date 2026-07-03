class CreateParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :participants do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :participants, :name
  end
end
