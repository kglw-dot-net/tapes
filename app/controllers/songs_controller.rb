class SongsController < ApplicationController
  # GET /songs
  def index
    @songs = Searcher.songs
  end

  # GET /songs/:slug
  def song
    @song = Song.find_by(slug: params[:slug])

    raise ActionController::RoutingError.new("Not Found") if @song.nil?

    dj_show_ids = Show
                    .includes(:show_tags)
                    .where(show_tags: { name: "DJ" })
                    .pluck(:id)

    @set_songs = SetSong
                   .includes(setlist: [ { show: [ { venue: :country }, :show_tags ] }, :set_type ])
                   .where(song_id: @song.id, setlists: { shows: { is_active: true } })
                   .where.not(setlist: { set_types: { name: "DJ Set" } })
                   .where.not(setlist: { show_id: dj_show_ids })
                   .order("shows.date DESC")
                   .all
  end
end
