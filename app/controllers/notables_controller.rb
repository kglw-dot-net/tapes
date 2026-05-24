class NotablesController < ApplicationController
  def twenty_minute_jams
    twentyMinsInSecs = 60 * 20

    @jams = SetSong
      .includes(:song)
      .includes(setlist: { show: { venue: :country } })
      .where(setlist: { shows: { is_active: true } })
      .where("set_songs.duration >= ?", twentyMinsInSecs)
      .order("shows.date DESC")
  end

  def curated
    @songs = SetSong
      .includes(:song)
      .includes(setlist: { show: { venue: :country } })
      .where(setlist: { shows: { is_active: true } })
      .where(is_jamchart: true)
      .order("shows.date DESC")
  end

  def upvoted
    @set_songs = SetSong
                   .includes(setlist: { show: { venue: :country } })
                   .where(setlists: { shows: { is_active: true } })
                   .where("set_songs.upvotes > ?", 3)
                   .order("set_songs.upvotes DESC")
                   .all
  end
end
