class WallParticipant < ApplicationRecord
  belongs_to :wall
  belongs_to :participant
end
