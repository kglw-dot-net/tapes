class Taper < ApplicationRecord
  belongs_to :parent, class_name: 'Taper', optional: true
  has_many :children, class_name: 'Taper', foreign_key: 'parent_id'
  has_many :recordings
end
