class RecordingFile < ApplicationRecord
  belongs_to :recording, optional: false
end
