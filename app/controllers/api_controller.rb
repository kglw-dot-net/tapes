class ApiController < ApplicationController
  before_action :set_cache_headers

  def shows
    shows = Rails.cache.fetch("api/shows.json", expires_in: 2.hours) do
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
            poster_url: show.poster_url
          }
        end
    end
    render json: shows
  end

  def show
    show_data = Rails.cache.fetch("api/shows/#{params[:id]}.json", expires_in: 2.hours) do
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

        kglw_net: {
          id: show.songfishID,
          permalink: show.songfishPermalink
        },

        venue_id: show.venue_id,
        tour_id: show.tour_id,

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
                title: file.title
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
    shows = Searcher.search(params[:q]&.strip)
                    .map do |show|
      {
        id: show.slug,
        date: show.date,
        venuename: show.venue.name,
        location: [ show.venue.city, show.venue.region, show.venue.country&.name ].reject { |s| s.blank? }.join(", "),
        title: show.title,
        order: show.order,
        poster_url: show.poster_url
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

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "public, max-age=#{2.hours.to_i}"
  end
end
