# frozen_string_literal: true

class Searcher
  CACHE_DURATION = 4.hours

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
    Rails.cache.fetch("Searcher.years", expires_in: CACHE_DURATION) do
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
    Rails.cache.fetch("Searcher.stats", expires_in: CACHE_DURATION) do
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

  def self.archival_uploads
    Rails.cache.fetch("Searcher.archival_uploads", expires_in: CACHE_DURATION) do
      Show
        .joins(:recordings)
        .includes(venue: :country)
        .where(is_active: true, recordings: { is_active: true })
        .select("shows.*, MIN(recordings.uploaded_at) AS oldest_upload")
        .group("shows.id")
        .having("(JULIANDAY(MIN(recordings.uploaded_at)) - JULIANDAY(shows.date)) >= 365")
        .order("oldest_upload DESC")
    end
  end

  def self.top_shows
    Rails.cache.fetch("Searcher.top_shows", expires_in: CACHE_DURATION) do
      Show
        .includes(venue: :country)
        .includes(:recordings)
        .where(is_active: true)
        .where("count_ratings >= ?", 3)
        .order(bayesian_rating: :desc, average_rating: :desc, count_ratings: :desc)
    end
  end

  def self.most_recent_shows
    Rails.cache.fetch("Searcher.most_recent_shows", expires_in: CACHE_DURATION) do
      Show
        .includes(venue: :country)
        .includes(:recordings)
        .where(is_active: true)
        .order(date: :desc, order: :desc)
    end
  end

  def self.today_shows
    month = Time.current.month.to_s.rjust(2, "0")
    day = Time.current.day.to_s.rjust(2, "0")

    Rails.cache.fetch("Searcher.today_shows(#{month},#{day})", expires_in: 24.hours) do
      Show
        .includes(venue: :country)
        .includes(:recordings)
        .where(is_active: true)
        .where("strftime('%m', date) = ? AND strftime('%d', date) = ?", month, day)
        .order(date: :desc, order: :desc)
    end
  end

  def self.songs
    Rails.cache.fetch("Searcher.songs", expires_in: CACHE_DURATION) do
      Song
        .includes(:album)
        .joins(set_songs: { setlist: :show })
        .joins(set_songs: { setlist: :set_type })
        .where(shows: { is_active: true })
        .where.not(set_types: { name: "DJ Set" })
        .select("songs.*, COUNT(DISTINCT shows.id) AS show_count")
        .group("songs.id")
        .to_a
    end
  end
end
