class Recording < ApplicationRecord
  belongs_to :show, optional: true
  belongs_to :recording_type, optional: true
  belongs_to :taper, optional: true
  has_many :recording_files
end
