class VenuesController < ApplicationController
  # GET /venues
  def index
    @venues_count = Venue
      .joins(:shows)
      .where(shows: { is_active: true })
      .distinct
      .count
    @countries = Country
      .joins(venues: :shows)
      .where(shows: { is_active: true })
      .distinct
      .order(:name)
      .all
  end

  # GET /venues/:country
  def country
    @country = Country.find_by(slug: params[:country])

    raise ActionController::RoutingError.new("Not Found") if @country.nil?

    @venues = Venue
      .joins(:shows)
      .where(country: @country, shows: { is_active: true })
      .distinct
      .order(:name)
      .all
  end

  # GET /venues/:country/:slug
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
