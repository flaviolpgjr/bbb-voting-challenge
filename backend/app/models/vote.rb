class Vote < ApplicationRecord
  belongs_to :wall
  belongs_to :participant
end
