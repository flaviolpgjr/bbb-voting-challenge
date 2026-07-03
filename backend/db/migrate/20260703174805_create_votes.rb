class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :wall, null: false, foreign_key: true
      t.references :participant, null: false, foreign_key: true

      t.string :ip_address, null: false
      t.string :user_agent

      t.timestamps
    end

    add_index :votes, :created_at
    add_index :votes, [:wall_id, :created_at]
    add_index :votes, [:participant_id, :created_at]
  end
end
