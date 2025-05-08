class Country < ApplicationRecord
  has_many :venues
  belongs_to :continent, optional: true
end
