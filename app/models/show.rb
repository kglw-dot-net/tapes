class Show < ApplicationRecord
  has_many :recordings
  has_many :setlists
  belongs_to :venue, optional: true
  belongs_to :tour, optional: true
end
