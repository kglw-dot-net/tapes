# TODO: Don't hardcode Songfish URL

require "json"
require "faraday"

module Songfish
  @@url = "https://kglw.net"

  def self.update
    Faraday.default_connection_options = { headers: { user_agent: "Gizz Tapes 2" } }

    updateVenues
    updateCountries
    updateSongs
    updateShows
    updateSetlists
    Tapes.calculateWeightedRatings
  end

  def self.full_update
    Faraday.default_connection_options = { headers: { user_agent: "Gizz Tapes 2" } }

    updateVenues
    updateCountries
    updateSongs
    updateShows(true)
    updateSetlists
    updateSongUpvotes
    Tapes.calculateWeightedRatings
  end

  def self.updateCountries
    puts "\tUpdating countries..."

    Country.where(slug: nil).each do |country|
      country.slug = country.name.parameterize
      country.save
    end
  end

  def self.updateVenues
    puts "\tUpdating venues..."

    url = URI.join(@@url, "/api/v2/venues")

    conn = Faraday.new(url) do |f|
      f.response :json
    end

    response = conn.get().body

    if response["error"]
      puts "\tError updating venues: #{response["error_message"]}"
      return
    end

    songfish_venues = response["data"]

    songfish_venues.each do |songfish_venue|
      venue = Venue.find_or_create_by(songfishID: songfish_venue["venue_id"])

      venue.name = songfish_venue["venuename"]
      venue.city = songfish_venue["city"]
      venue.region = songfish_venue["state"]
      venue.slug = songfish_venue["slug"]

      venue.country = Country.find_or_create_by(name: songfish_venue["country"])

      venue.save
    end
  end

  def self.updateSongs
    url = URI.join(@@url, "/api/v2/songs")

    conn = Faraday.new(url) do |f|
      f.response :json
    end

    response = conn.get().body

    if response["error"]
      puts "\tError updating songs: #{response["error_message"]}"
      return
    end

    songfish_songs = response["data"]

    songfish_songs.each do |songfish_song|
      song = Song.find_or_create_by(songfishID: songfish_song["id"])

      song.name = songfish_song["name"]
      song.slug = songfish_song["slug"]
      song.is_original = songfish_song["isoriginal"]

      song.save
    end
  end

  def self.updateSongUpvotes
    puts "\tUpdating upvotes..."

    Song.joins(set_songs: { setlist: :show })
        .where(shows: { is_active: true })
        .distinct
        .each do |song|
      url = URI.join(@@url, "/song/#{song.slug}")
      page = Faraday.new.get(url).body
      doc = Nokogiri::HTML(page)

      table = doc.at_css("#tabletwitter\\:description")

      next unless table

      table.css("tbody tr").each do |row|
        cells = row.css("td")

        upvote_count = cells[0]&.at_css(".upvote-count")&.text&.to_i || 0
        show_date = cells[1]&.at_css("a")&.[]("href")&.sub!("/setlists/?date=", "")
        location = cells[2]&.text
        track_time = cells[5]&.text

        previous_song_name = cells[6]&.at_css("a")&.text
        previous_song_slug = cells[6]&.at_css("a")&.[]("href")&.sub!("/song/", "")

        next_song_name = cells[7]&.at_css("a")&.text
        next_song_slug = cells[7]&.at_css("a")&.[]("href")&.sub!("/song/", "")

        seconds = getDuration track_time
        venue_name = location.nil? ? nil : location.split(", ")[0]

        set_songs = SetSong
                      .joins(setlist: { show: :venue })
                      .where(shows: { date: show_date })
                      .where(song_id: song.id)
                      .all

        set_songs = set_songs.where(duration: seconds)
        set_songs = set_songs.where("venues.name LIKE ?", "#{venue_name}%") unless venue_name.nil?

        if set_songs.length == 0
          puts "\t\tCould not find SetSong for #{song.id} (#{song.name}) on #{show_date} with duration #{seconds} and venue #{venue_name}"
          next
        end

        if set_songs.length > 1
          if previous_song_name.nil?
            set_songs = set_songs.where(position: 1)
          else
            previous_songs = SetSong
                              .joins(setlist: { show: :venue })
                              .joins(:song)
                              .where(shows: { date: show_date })
                              .where(song: { slug: previous_song_slug })
                              .all
            previous_songs = previous_songs.where("venues.name LIKE ?", "#{venue_name}%") unless venue_name.nil?

            if previous_songs.length == 1
              position = previous_songs.sole.position + 1
              set_songs = set_songs.where(position: position)
            else
              next_songs = SetSong
              .joins(setlist: { show: :venue })
              .joins(:song)
              .where(shows: { date: show_date })
              .where(song: { slug: next_song_slug })
              .all
              next_songs = next_songs.where("venues.name LIKE ?", "#{venue_name}%") unless venue_name.nil?

              if next_songs.length == 1
                position = next_songs.sole.position - 1
                set_songs = set_songs.where(position: position)
              end
            end
          end

          if set_songs.length > 1
            puts set_songs.to_sql
            puts "\t\tToo many SetSongs for #{song.id} (#{song.name}) on #{show_date} with duration #{seconds}, venue #{venue_name} and previous track #{previous_song_name}"
            next
          end
        end

        set_songs.sole.update(upvotes: upvote_count)
      end
    end
  end

  # Convert string e.g. "1:23" to number of seconds e.g. 83.0
  def self.getDuration(time)
    return nil if time.blank?

    parts = time.split(":")
    return nil if parts.length != 2

    minutes = parts[0].to_i
    seconds = parts[1].to_i

    minutes * 60 + seconds
  end

  def self.updateSetlists
    puts "\tUpdating setlists..."

    songfish_set_song_ids = []

    (2010..Time.current.year).each do |year|
      puts "\t\tUpdating setlists for #{year}..."

      setlists = getSetlistsForYear(year)

      setlists.each do |setlist|
        songfish_set_song_ids << setlist["uniqueid"]

        show_id = Show.find_by(songfishID: setlist["show_id"])&.id
        set = Setlist.find_or_create_by(show_id: show_id, setnumber: setlist["setnumber"])

        set.set_type = SetType.find_or_create_by(name: setlist["settype"])

        set.save!

        song = Song.find_by(songfishID: setlist["song_id"])

        next if song.nil?

        set_song = SetSong.find_or_create_by(songfishID: setlist["uniqueid"])

        set_song.setlist_id = set.id
        set_song.song = song
        set_song.position = setlist["position"]
        set_song.duration = getDuration(setlist["tracktime"])
        set_song.footnote = setlist["footnote"]
        set_song.is_jamchart = setlist["isjamchart"]
        set_song.jamchart_notes = setlist["jamchart_notes"]
        set_song.is_reprise = setlist["isreprise"]
        set_song.is_verified = setlist["isverified"]
        set_song.is_recommended = setlist["isrecommended"]
        set_song.is_jam = setlist["isjam"]

        transition = Transition.find_or_create_by(songfishID: setlist["transition_id"])

        transition.separator = setlist["transition"]

        transition.save

        set_song.transition = transition

        set_song.save

        # opener	""
        # soundcheck	""
        # css_class	null
      end
    end

    SetSong.where.not(songfishID: songfish_set_song_ids).destroy_all
  end

  def self.getUploads
    url = URI.join(@@url, "/api/v2/uploads")

    conn = Faraday.new(url) do |f|
      f.response :json
    end

    response = conn.get().body

    if response["error"]
      puts "\tError getting uploads: #{response["error_message"]}"
      return []
    end

    response["data"]
  end

  def self.getSetlistsForYear(year)
    url = URI.join(@@url, "/api/v2/setlists/showyear/#{year}")

    conn = Faraday.new(url) do |f|
      f.response :json
    end

    response = conn.get().body

    if response["error"]
      puts "\tError getting #{year} setlists: #{response["error_message"]}"
      return []
    end

    response["data"]
  end

  def self.getPosterUrlFromWebScraper(doc)
    poster_link = doc.at_css("#setlist-card-poster-art a")
    poster_link&.attr("href")
  end

  def self.getRatings
    url = URI.join(@@url, "/charts/top-rated")
    site = Faraday.new.get(url).body
    doc = Nokogiri::HTML(site)
    table = doc.at_css("table.table.table-striped.sortable")
    return [] unless table

    table.css("tbody tr").filter_map do |row|
      cells = row.css("td")

      rating = Float(cells[0]&.text&.strip) rescue nil
      count = Integer(cells[1]&.text&.strip) rescue nil

      link = cells[2]&.at_css("a")
      show_link = link&.[]("href")

      next if rating.nil? || count.nil? || show_link.nil?

      { rating: rating, count: count, show_link: show_link.sub!("/setlists/", "") }
    end
  end

  def self.updateShows(is_replace_posters = false)
    puts "\tUpdating shows..."

    uploads = getUploads
    ratings = getRatings

    # TODO: Don't hardcode starting year
    (2010..Time.current.year).each do |year|
      puts "\t\tUpdating shows for #{year}..."

      url = URI.join(@@url, "/api/v2/shows/show_year/#{year}")

      conn = Faraday.new(url) do |f|
        f.response :json
      end

      response = conn.get().body

      if response["error"]
        puts "\t\tError updating shows for #{year}: #{response["error_message"]}"
        next
      end

      songfish_shows = response["data"]

      setlists = getSetlistsForYear(year)

      songfish_shows.each do |songfish_show|
        show = Show.find_or_create_by(songfishID: songfish_show["show_id"])

        show.date = songfish_show["showdate"]
        show.venue = Venue.find_by(songfishID: songfish_show["venue_id"])

        show.tour = Tour.find_or_create_by(songfishID: songfish_show["tour_id"])
        show.tour.update(name: songfish_show["tourname"]) if show.tour.name != songfish_show["tourname"]

        show.show_tags = (songfish_show["show_tags"] || []).map do |tag_data|
          tag = ShowTag.find_or_create_by(slug: tag_data["tag_slug"])
          tag.update(name: tag_data["tag"]) if tag.name != tag_data["tag"]
          tag
        end

        # show.artist = Artist.find_by(songfishID: songfish_show["artist_id"])
        show.songfishPermalink = songfish_show["permalink"]
        show.title = songfish_show["showtitle"].empty? ? nil : songfish_show["showtitle"]
        show.order = songfish_show["showorder"]

        setlist = setlists.find { |s| s["show_id"] == songfish_show["show_id"] }

        if setlist
          show.notes = setlist["shownotes"]
        end

        doc = nil

        # show.notes = setlists[0]["notes"] unless setlists.nil? or setlists.empty?

        poster_upload = uploads.find { |u| u["show_id"] == songfish_show["show_id"].to_s and u["upload_type"] == "poster-art" }

        if poster_upload
          show.poster_url = poster_upload["URL"]
        else
          if show.poster_url.blank? or is_replace_posters
            doc = scrapeShowPage(show) if doc.nil?
            poster_url = getPosterUrlFromWebScraper(doc)
            show.poster_url = poster_url unless poster_url.nil?
          end
        end

        rating = ratings.find { |r| r[:show_link] == show.songfishPermalink }

        if rating.nil?
          doc = scrapeShowPage(show) if doc.nil?

          show.count_ratings = doc.at_css("#sf-rating-count").text.strip.to_i
          show.average_rating = show.count_ratings == 0 ? nil : doc.at_css("#sf-rating-avg").text.strip.to_f
        else
          show.count_ratings = rating[:count]
          show.average_rating = rating[:rating]
        end

        show.save
      end
    end
  end

  def self.scrapeShowPage(show)
    url = URI.join(@@url, "/setlists/#{show.songfishPermalink}")
    site = Faraday.new.get(url).body
    Nokogiri::HTML(site)
  end

  def self.loadOverrides(path)
    overrides = YAML.load_file(path)

    overrides.each do |override|
      show = Show.find_by(songfishID: override["kglwnetid"])

      next if show.nil?

      if override["ignore"] == true
        show.is_active = false
      end

      unless override["path"].blank?
        show.slug = override["path"]
      end

      show.save

      next if override["archiveids"].nil?

      override["archiveids"].each do |archiveid|
        recording = Recording.find_by(id: archiveid)
        recording.update(show_id: show.id) unless recording.nil? or recording.show_id == show.id
      end
    end
  end
end
