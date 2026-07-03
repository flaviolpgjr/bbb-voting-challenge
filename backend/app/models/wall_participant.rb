class WallParticipant < ApplicationRecord
  belongs_to :wall
  belongs_to :participant

  validates :participant_id, uniqueness: { scope: :wall_id }
end