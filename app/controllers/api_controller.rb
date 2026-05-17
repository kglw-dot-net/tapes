require 'cgi'

class ApiController < ApplicationController
  before_action :set_cache_headers

  def shows
    shows = Rails.cache.fetch("api/shows.json", expires_in: 4.hours) do
      Show
        .where(is_active: true)
        .map do |show|
        {
          id: show.slug,
          date: show.date,
          venuename: show.venue.name,
          location: [ show.venue.city, show.venue.region, show.venue.country&.name ].reject { |s| s.blank? }.join(", "),
          title: show.title,
          order: show.order,
          poster_url: show.poster_url,
          average_rating: show.average_rating,
          count_ratings: show.count_ratings,
          weighted_rating: show.bayesian_rating
        }
      end
    end
    render json: shows
  end

  def show
    show_data = Rails.cache.fetch("api/shows/#{params[:id]}.json", expires_in: 4.hours) do
      show = Show.find_by(slug: params[:id], is_active: true) ||
             Show.find_by(songfishID: params[:id], is_active: true)

      next nil if show.nil?

      {
        id: show.slug,
        date: show.date,
        order: show.order,
        poster_url: show.poster_url,
        notes: show.notes,
        title: show.title,

        average_rating: show.average_rating,
        count_ratings: show.count_ratings,
        weighted_rating: show.bayesian_rating,

        kglw_net: {
          id: show.songfishID,
          permalink: show.songfishPermalink
        },

        venue_id: show.venue_id,
        tour_id: show.tour_id,

        sets: show.setlists.map do |setlist|
          {
            number: setlist.setnumber,
            set_type_id: setlist.set_type_id,
            set_type: setlist.set_type&.name,
            songs: setlist.set_songs.order(:position).map do |set_song|
              {
                song: {
                  id: set_song.song_id,
                  slug: set_song.song.slug,
                  name: set_song.song.name
                },
                position: set_song.position,
                duration: set_song.duration,
                footnote: set_song.footnote,
                is_notable: set_song.is_jamchart,
                notable_description: set_song.jamchart_notes,
                transition: set_song.transition&.separator
              }
            end
          }
        end,

        recordings: show.recordings.where(is_active: true).map do |recording|
          {
            id: recording.id,
            uploaded_at: recording.uploaded_at,
            type: recording.recording_type&.name,
            source: recording.source,
            lineage: recording.lineage,
            taper: recording.taper&.name,
            files_path_prefix: "https://archive.org/download/" + recording.id + "/",

            internet_archive: {
              is_lma: recording.is_lma
            },

            files: recording.recording_files.where("name LIKE :ext", ext: "%#{recording.preferred_format}").map do |file|
              {
                filename: file.name,
                length: file.length,
                title: file.title_override || file.title
              }
            end
          }
        end
      }
    end

    raise ActionController::RoutingError.new("Not Found") if show_data.nil?

    render json: show_data
  end

  def search
    query = params[:q]&.strip

    # Using CGI.parse as it can handle multiple set_type_id values, e.g. ?set_type_id=1&set_type_id=2
    x = CGI.parse request.query_string
    set_type_id = x["set_type_id"].present? ? x["set_type_id"].map(&:to_i).presence : nil

    shows = Searcher.search(query, set_type_id)
                    .map do |show|
      {
        id: show.slug,
        date: show.date,
        venuename: show.venue.name,
        location: [ show.venue.city, show.venue.region, show.venue.country&.name ].reject { |s| s.blank? }.join(", "),
        title: show.title,
        order: show.order,
        poster_url: show.poster_url,
        average_rating: show.average_rating,
        count_ratings: show.count_ratings,
        weighted_rating: show.bayesian_rating
      }
    end

    render json: shows
  end

  def years
    render json: Searcher.years
  end

  def stats
    render json: Searcher.stats
  end

  def venues
    venues = Rails.cache.fetch("api/venues.json", expires_in: 4.hours) do
      Venue
        .joins(:shows)
        .where(shows: { is_active: true })
        .distinct
        .map do |venue|
        {
          id: venue.id,
          slug: venue.slug,
          name: venue.name,
          city: venue.city,
          region: venue.region,
          country_id: venue.country_id,
          show_count: venue.shows.where(is_active: true).count
        }
      end
    end

    render json: venues
  end

  def countries
    countries = Rails.cache.fetch("api/countries.json", expires_in: 4.hours) do
      Country
        .joins(venues: :shows)
        .where(shows: { is_active: true })
        .distinct
        .map do |country|
        {
          id: country.id,
          name: country.name,
          show_count: country.venues.joins(:shows).where(shows: { is_active: true }).count
        }
      end
    end

    render json: countries
  end

  def songs
    songs = Rails.cache.fetch("api/songs.json", expires_in: 4.hours) do
      Searcher.songs.map do |song|
        {
          id: song.id,
          slug: song.slug,
          name: song.name,
          show_count: song.show_count,
          album_id: song.album_id,
          track_number: song.track_number
        }
      end
    end

    render json: songs
  end

  def song
    song = Song.find_by(slug: params[:slug])

    raise ActionController::RoutingError.new("Not Found") if song.nil?

    render json: {
      id: song.id,
      slug: song.slug,
      name: song.name,
      album_id: song.album_id,
      track_number: song.track_number,
      shows: song.set_songs
                 .joins(setlist: :show)
                 .where(setlists: { shows: { is_active: true } })
                 .map do |set_song|
        {
          id: set_song.setlist.show.id,
          is_notable: set_song.is_jamchart,
          notable_description: set_song.jamchart_notes
        }
      end
    }
  end

  def albums
    albums = Rails.cache.fetch("api/albums.json", expires_in: 4.hours) do
      Album
        .all
        .map do |album|
        {
          id: album.id,
          title: album.title,
          cover_art_url: album.cover_art_url,
          subtitle: album.subtitle,
          release_date: album.release_date
        }
      end
    end

    render json: albums
  end

  def set_types
    set_types = Rails.cache.fetch("api/set_types.json", expires_in: 4.hours) do
      SetType
        .all
        .map do |set_type|
        {
          id: set_type.id,
          name: set_type.name,
          show_count: set_type.setlists.joins(:show).where(shows: { is_active: true }).count
        }
      end
    end

    render json: set_types
  end

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "public, max-age=#{4.hours.to_i}"
  end
end
