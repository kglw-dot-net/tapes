class NotablesController < ApplicationController
  # get "notables/20-minute-jams" => "notables#20_minute_jams"
  def twenty_minute_jams
    twentyMinsInSecs = 60 * 20

    @jams = SetSong
      .includes(:song)
      .includes(setlist: { show: { venue: :country } })
      .where(setlist: { shows: { is_active: true } })
      .where("set_songs.duration >= ?", twentyMinsInSecs)
      .order("shows.date DESC")
  end

  # get "notables/curated" => "notables#curated"
  def curated
    @songs = SetSong
      .includes(:song)
      .includes(setlist: { show: { venue: :country } })
      .where(setlist: { shows: { is_active: true } })
      .where(is_jamchart: true)
      .order("shows.date DESC")
  end
end
