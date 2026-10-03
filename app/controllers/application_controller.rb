class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  before_action :set_layout_data

  def feed
    @shows = Show
               .joins(:recordings)
               .includes(venue: :country)
               .where(is_active: true, recordings: { is_active: true })
               .select("shows.*, MIN(recordings.uploaded_at) AS oldest_upload, MAX(recordings.uploaded_at) AS latest_upload")
               .group("shows.id")
               .order("oldest_upload DESC")
               .limit(25)
               .all

    respond_to do |format|
      format.xml { render layout: false }
    end
  end

  private

  def set_layout_data
    @artists = Rails.cache.fetch("non_main_artists_with_active_shows", expires_in: 1.day) do
      Artist
        .joins(:shows)
        .where(shows: { is_active: true })
        .select("artists.*, COUNT(shows.id) as show_count, MAX(shows.poster_url) as poster_url")
        .group("artists.id")
        .order(Arel.sql("show_count DESC"))
        .to_a
        .drop(1)
        .sort_by(&:name)
    end

    @show_tags = Rails.cache.fetch("show_tags_with_active_shows", expires_in: 2.hours) do
      ShowTag
        .joins(:shows)
        .where(shows: { is_active: true })
        .distinct
        .order(:name)
        .to_a
    end
  end
end
