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

  def self.years
    Rails.cache.fetch("Searcher.years", expires_in: 2.hours) do
      Show
        .select(<<~SQL)
      CAST(strftime('%Y', shows.date) AS INTEGER) AS year,
      COUNT(*) AS show_count,
      COALESCE(
        (SELECT yt.poster_url FROM year_thumbnails yt WHERE yt.year = strftime('%Y', shows.date) LIMIT 1),
        MAX(CASE WHEN shows.poster_url IS NOT NULL THEN shows.poster_url ELSE '' END)
      ) AS poster_url
    SQL
        .where(is_active: true)
        .group("year")
        .order("year DESC")
        .map do |x|
        {
          year: x.year,
          show_count: x.show_count,
          poster_url: x.poster_url
        }
        end
    end
  end

  def self.stats
    Rails.cache.fetch("Searcher.stats", expires_in: 2.hours) do
      total_minutes = RecordingFile.joins(recording: :show)
                                   .where("recording_files.name LIKE '%' || recordings.preferred_format")
                                   .where(recordings: { is_active: true, shows: { is_active: true } })
                                   .sum(:length) / 60

      {
        latest_year: Show.where(is_active: true).maximum(:date)&.year,
        earliest_year: Show.where(is_active: true).minimum(:date)&.year,

        total_shows: Show.where(is_active: true).count,
        total_recordings: Recording.joins(:show)
                                    .where(is_active: true, shows: { is_active: true })
                                    .count,

        hours: (total_minutes / 60).floor,
        minutes: (total_minutes % 60).floor,

        sbd_count: Recording.joins(:recording_type, :show)
                            .where(is_active: true, recording_types: { name: "SBD" }, shows: { is_active: true })
                            .count,

        aud_count: Recording.joins(:recording_type, :show)
                             .where(is_active: true, recording_types: { name: "AUD" }, shows: { is_active: true })
                             .count
      }
    end
  end
end
