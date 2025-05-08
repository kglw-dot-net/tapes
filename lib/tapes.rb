module Tapes
  def setDefaults
    puts "For each show without a slug, if there is only one show with the same date, set the slug to date in YYYY-MM-DD format"
    Show.where(slug: [ nil, "" ])
      .where(is_active: nil)
      .find_each do |show|
      next if Show.where(date: show.date).count > 1
      show.update(slug: show.date.strftime("%Y-%m-%d"))
    end

    puts "If there are multiple active shows with the same slug, set them both to is_active: nil"
    Show.where.not(slug: [ nil, "" ])
      .where(is_active: true)
      .group(:slug)
      .having("COUNT(*) > 1")
      .find_each do |show|
      Show.where(slug: show.slug)
        .where(is_active: true)
        .update_all(is_active: nil)
    end

    puts "Matching recordings to shows based on dates..."
    Recording.where(show_id: nil)
      .where(is_active: nil)
      .find_each do |recording|
      shows = Show.where(date: recording.recorded_at)
        .where(is_active: true)
        .or(Show.where(date: recording.recorded_at).where(is_active: nil))
      next if shows.count != 1
      recording.update(show_id: shows.sole.id)
    end

    puts "Setting default recording formats..."
    Recording.where(preferred_format: [ nil, "" ])
      .where(is_active: nil)
      .joins(:recording_files)
      .where("LOWER(recording_files.name) LIKE ?", "%.mp3")
      .or(
        Recording.where(preferred_format: [ nil, "" ])
          .where(is_active: nil)
          .joins(:recording_files)
          .where("LOWER(recording_files.name) LIKE ?", "%.m4a")
      )
      .find_each do |recording|
      if RecordingFile.any? { |f| f.recording_id == recording.id and f.name.downcase.end_with? "mp3" }
        puts "\tSetting default recording format for recording #{recording.id} to MP3..."
        recording.update(preferred_format: "MP3")
      else
        if RecordingFile.any? { |f| f.recording_id == recording.id and f.name.downcase.end_with? "m4a" }
          puts "\tSetting default recording format for recording #{recording.id} to M4A..."
          recording.update(preferred_format: "M4A")
        end
      end
    end

    puts "Setting LMA recordings active..."
    Recording.where(is_lma: true)
      .where.not(preferred_format: [ nil, "" ])
      .where.not(show_id: nil)
      .where.not(recording_type_id: nil)
      .where(is_active: nil)
      .find_each do |recording|
      recording.is_active = true
      recording.save
    end

    puts "Setting community audio uploads active..."
    Recording.where(is_lma: false)
      .where.not(preferred_format: nil)
      .where.not(show_id: nil)
      .where.not(recording_type_id: nil)
      .where(is_active: nil)
      .find_each do |recording|
      showLMAUploads = Recording.where(show_id: recording.show_id)
        .where(is_lma: true)

      # If this community audio upload is already active, only deactivate it once the LMA upload is active
      if recording.is_active
        showLMAUploads = showLMAUploads.where(is_active: true)
      end

      recording.is_active = !showLMAUploads.exists?

      recording.save
    end

    puts "Setting shows active..."
    Show.where(is_active: nil)
      .where.not(slug: [ nil, "" ])
      .joins(:recordings)
      .where("recordings.is_active = ?", true)
      .distinct
      .find_each do |show|
      show.is_active = true
      show.save
    end
  end

  def setShowColors
    Show.where(color: nil)
      .find_each do |show|
        puts "\tSetting color for show #{show.slug || show.id}..."
        color = getAvgColor(show.poster_url)
        show.update(color: color) unless color.nil?
      end
  end

  # Get the average color of an image from a URL
  # Outputs 'r, g, b' where r, g, and b are integers between 0 and 255
  def getAvgColor(url)
    return nil if url.nil?

    uri = URI.parse(url)
    return nil unless uri.is_a?(URI::HTTP) or uri.is_a?(URI::HTTPS)

    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    image = MiniMagick::Image.open(uri.to_s)
    image.resize "1x1"

    color = image["%[pixel:u.p{0,0}]"]

    return nil if color.blank?

    # Color will be e.g. 'srgb(103,102,100)' -- we just want 103,102,100
    color.gsub("srgb(", "").gsub(")", "")
  end

  def importAlbums(path)
    ymlalbums = YAML.load_file(path)

    ymlalbums.each do |ymlalbum|
      puts "Loading album #{ymlalbum["title"]}..."

      album = Album.find_or_create_by(title: ymlalbum["title"])

      album.update(
        year: ymlalbum["year"],
        cover_art_url: ymlalbum["image"],
      )

      ymlalbum["songs"].each do |ymlsong|
        song = Song.find_by!(songfishID: ymlsong)
        song.update(album_id: album.id)
      end
    end
  end
end
