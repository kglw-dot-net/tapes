class SearchController < ApplicationController
  def index
    @query = params[:q]&.strip

    if !@query.blank? and @query.length > 3
      @shows = Show.joins(venue: :country)
                   .where(is_active: true)
                   .where(
                     "date LIKE :q OR
                      title LIKE :q OR
                      venues.name LIKE :q OR
                      venues.city LIKE :q OR
                      venues.region LIKE :q OR
                      countries.name LIKE :q",
                     q: "%#{@query}%"
                   )
    end
  end
end
