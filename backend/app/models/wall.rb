class Wall < ApplicationRecord
  has_many :wall_participants, dependent: :destroy
  has_many :participants, through: :wall_participants
  has_many :votes, dependent: :restrict_with_exception

  validates :name, :starts_at, :ends_at, presence: true
end