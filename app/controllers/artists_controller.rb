class ArtistsController < ApplicationController
  def index
  end

  def show
    @artist = Artist.find_by(slug: params[:id])
    @shows = @artist.shows.where(is_active: true)
  end
end
