# frozen_string_literal: true

class Searcher
  def self.search(query)
    return [] if query.blank? or query.length < 3

    Show.joins(venue: :country)
        .joins(setlists: { set_songs: :song })
        .where(is_active: true)
        .where(
          "date LIKE :q OR
        title LIKE :q OR
        venues.name LIKE :q OR
        venues.city LIKE :q OR
        venues.region LIKE :q OR
        countries.name LIKE :q OR
        songs.name LIKE :q",
          q: "%#{query}%"
        )
        .distinct
  end
end
