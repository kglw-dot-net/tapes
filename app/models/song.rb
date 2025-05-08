class Song < ApplicationRecord
  belongs_to :album, optional: true
  has_many :set_songs
end
