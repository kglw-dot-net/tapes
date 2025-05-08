class VenuesController < ApplicationController
  # GET /venues
  def index
    @venues = Venue
      .joins(:shows)
      .where(shows: { is_active: true })
      .distinct
      .all
  end

  # GET /venues/:slug
  def venue
    @venue = Venue.find_by(slug: params[:slug])

    raise ActionController::RoutingError.new("Not Found") if @venue.nil?

    @shows = Show
      .includes(:recordings)
      .includes(venue: :country)
      .where(venue: @venue, is_active: true)
      .order(date: :desc)
      .all
  end
end
