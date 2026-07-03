class Vote < ApplicationRecord
  belongs_to :wall
  belongs_to :participant

  validates :ip_address, presence: true
end