class Venue < ApplicationRecord
  has_many :shows
  belongs_to :country, optional: true
end
