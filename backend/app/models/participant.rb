class Participant < ApplicationRecord
  has_many :wall_participants, dependent: :destroy
  has_many :walls, through: :wall_participants
  has_many :votes, dependent: :restrict_with_exception

  validates :name, presence: true
end