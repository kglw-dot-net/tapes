class RecordingFile < ApplicationRecord
  belongs_to :recording, optional: false

  scope :matching_format, ->(format) {
    where("name LIKE ?", "%#{format}")
  }
end
