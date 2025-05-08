class Show < ApplicationRecord
  has_many :recordings
  belongs_to :venue, optional: true
  belongs_to :tour, optional: true
end
