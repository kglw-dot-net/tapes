class Artist < ApplicationRecord
  has_many :shows

  def to_param
    slug
  end

  def to_s
    name
  end
end
