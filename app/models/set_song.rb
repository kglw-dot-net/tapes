class SetSong < ApplicationRecord
  belongs_to :setlist
  belongs_to :song
  belongs_to :transition, optional: true
end
