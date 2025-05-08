class SongsController < ApplicationController
  # GET /songs
  def index
    @songs = Song
      .includes(:album)
      .joins(set_songs: { setlist: :show })
      .where(shows: { is_active: true })
      .distinct
      .all

    # If I could do this within the above query, I would
    # SELECT set_songs.song_id, COUNT(*) FROM "set_songs" INNER JOIN "setlists" "setlist" ON "setlist"."id" = "set_songs"."setlist_id" INNER JOIN "shows" ON "shows"."id" = "setlist"."show_id" WHERE "set_songs"."song_id" = 470 AND "shows"."is_active" = 1 GROUP BY set_songs.song_id
    @song_show_counts = SetSong
      .joins(setlist: :show)
      .where(shows: { is_active: true })
      .group(:song_id)
      .select("set_songs.song_id, COUNT(*) AS show_count")
      .to_a
  end

  # GET /songs/:slug
  def song
    @song = Song.find_by(slug: params[:slug])

    raise ActionController::RoutingError.new("Not Found") if @song.nil?

    @shows = Show
      .includes(:recordings)
      .includes(venue: :country)
      .joins(setlists: { set_songs: :song })
      .where(songs: { id: @song.id }, shows: { is_active: true })
      .distinct
      .order(date: :desc)
      .all
  end
end
