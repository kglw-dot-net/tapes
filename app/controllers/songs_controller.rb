class SongsController < ApplicationController
  # GET /songs
  def index
    @songs = Searcher.songs
  end

  # GET /songs/:slug
  def song
    @song = Song.find_by(slug: params[:slug])

    raise ActionController::RoutingError.new("Not Found") if @song.nil?

    @set_songs = SetSong
      .includes(setlist: { show: { venue: :country } })
      .where(song_id: @song.id, setlists: { shows: { is_active: true } })
      .order("shows.date DESC")
      .all
  end
end
