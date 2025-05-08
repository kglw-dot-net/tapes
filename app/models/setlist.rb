class Setlist < ApplicationRecord
  belongs_to :show
  belongs_to :set_type
  has_many :set_songs
end
