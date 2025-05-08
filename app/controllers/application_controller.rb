class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def feed
    @shows = Show
      .joins(:recordings)
      .includes(venue: :country)
      .where(is_active: true, recordings: { is_active: true })
      .select('shows.*, MIN(recordings.uploaded_at) AS oldest_upload, MAX(recordings.uploaded_at) AS latest_upload')
      .group('shows.id')
      .order('oldest_upload DESC')
      .limit(25)
      .all

    respond_to do |format|
      format.xml { render layout: false }
    end
  end
end
