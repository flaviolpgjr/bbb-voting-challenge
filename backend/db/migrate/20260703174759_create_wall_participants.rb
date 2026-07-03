class CreateWallParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :wall_participants do |t|
      t.references :wall, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true

      t.timestamps
    end

    add_index :wall_participants,
              [:wall_id, :participant_id],
              unique: true,
              name: "idx_wall_participant_unique"
  end
end
