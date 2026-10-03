class Show < ApplicationRecord
  has_many :recordings
  has_many :setlists

  has_and_belongs_to_many :show_tags

  belongs_to :artist, optional: true
  belongs_to :tour, optional: true
  belongs_to :venue, optional: true

  def to_param = slug
end
