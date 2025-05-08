# TODO: Don't hardcode Songfish URL

require "json"
require "faraday"

module Songfish
  @@url = "https://kglw.net"

  def update
    updateVenues
    updateSongs
    updateShows
  end

  def updateVenues
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

  def updateSongs
  end

  def getUploads
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


  def getSetlistsForYear(year)
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

  def getPosterUrlFromWebScraper(permalink)
    url = URI.join(@@url, "/setlists/#{permalink}")
    site = Faraday.new.get(url).body
    doc = Nokogiri::HTML(site)
    poster_link = doc.at_css("#setlist-card-poster-art a")
    poster_link&.attr("href")
  end

  def updateShows(is_replace_posters = false)
    puts "\tUpdating shows..."

    uploads = getUploads

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

        # show.artist = Artist.find_by(songfishID: songfish_show["artist_id"])
        show.songfishPermalink = songfish_show["permalink"]
        show.title = songfish_show["showtitle"].empty? ? nil : songfish_show["showtitle"]
        show.order = songfish_show["showorder"]

        setlist = setlists.find { |s| s["show_id"] == songfish_show["show_id"] }

        if setlist
          show.notes = setlist["shownotes"]
        end

        # show.notes = setlists[0]["notes"] unless setlists.nil? or setlists.empty?

        poster_upload = uploads.find { |u| u["show_id"] == songfish_show["show_id"].to_s and u["upload_type"] == "poster-art" }

        if poster_upload
          show.poster_url = poster_upload["URL"]
        else
          if show.poster_url.blank? or is_replace_posters
            poster_url = getPosterUrlFromWebScraper(show.songfishPermalink)
            show.poster_url = poster_url unless poster_url.nil?
          end
        end

        show.save
      end
    end
  end

  def loadOverrides(path)
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
