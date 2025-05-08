# TODO: Don't hardcode search query

require "json"
require "faraday"

module InternetArchive
  @@searchQuery = 'collection:KingGizzardAndTheLizardWizard OR creator:"King Gizzard & The Lizard Wizard" OR subject:"KGLW" OR subject:"kgatlw" OR subject:"king gizzard" OR subject:"king gizzard & the lizard wizard"'

  def update
    identifiers = getUploads

    identifiers.each { |identifier| updateRecording(identifier, true) }
  end

  def runInternetArchiveSearch(query)
    searchResults = []
    urlEncodedQuery = URI.encode_www_form_component(query)
    pageNo = 1

    while true
      puts "\tDownloading page #{pageNo} of search results..."

      url = "https://archive.org/advancedsearch.php?q=#{urlEncodedQuery}&fl%5B%5D=identifier&sort%5B%5D=identifier+asc&rows=50&page=#{pageNo}&output=json"

      conn = Faraday.new(url) do |f|
        f.response :json
      end

      data = conn.get().body

      break if data["response"]["docs"].empty?

      searchResults.push(*data["response"]["docs"])

      pageNo += 1
    end

    searchResults
  end

  def getUploads
    runInternetArchiveSearch(@@searchQuery).map { |x| x["identifier"] }
  end

  def updateRecording (identifier, is_create_only = false)
    return nil if is_create_only and Recording.exists?(id: identifier)

    puts "\tUpdating recording #{identifier}..."

    url = "https://archive.org/metadata/#{identifier}"

    conn = Faraday.new(url) do |f|
      f.response :json
    end

    response = conn.get().body

    return nil if response.blank? or
      response["metadata"].nil? or
        response["files"].nil? or
        response["files"].empty?

    recording = Recording.find_or_create_by(id: identifier)

    recording.recorded_at = response["metadata"]["date"] if recording.recorded_at.nil?
    recording.uploaded_at = response["metadata"]["addeddate"]

    recording.source = response&.dig("metadata", "source")
    recording.lineage = response&.dig("metadata", "lineage")
    recording.notes = response&.dig("metadata", "description")

    recording.is_lma = response&.dig("metadata", "mediatype")&.downcase == "etree"

    taper = response&.dig("metadata", "taper")

    recording.taper = taper.present? ? Taper.find_or_create_by(name: taper) : nil

    recording.save

    response["files"].each do |file|
      recording_file = RecordingFile.find_or_create_by(recording_id: identifier, name: file["name"])

      recording_file.source = file["source"]
      recording_file.format = file["format"]
      recording_file.length = getFileLength(file["length"])
      recording_file.original = file["original"]
      recording_file.title = file["title"]
      recording_file.track_no = file["track"]
      recording_file.is_private = file["private"]
      recording_file.creator = file["creator"]
      recording_file.album = file["album"]
      recording_file.url = "https://archive.org/download/#{identifier}/#{file["name"]}"

      recording_file.save
    end
  end

  def getFileLength(x)
    return nil if x.nil?
    return x.to_f if x.include?(".")

    if x.include?(":")
      y = x.split(":")
      return 60 * y[0].to_i + y[1].to_i
    end

    x.to_i
  end

  def loadOverrides(path)
    puts "\tLoading overrides from path..."

    overrides = YAML.load_file(path)

    puts "\tSaving overrides..."

    overrides.each do |override|
      puts "\t\t#{override["identifier"]}"
      recording = Recording.find_by(id: override["identifier"])

      next if recording.nil?

      if override["ignore"] == true
        recording.is_active = false
      end

      unless override["extension"].blank?
        recording.preferred_format = override["extension"].upcase.gsub(".", "")
      end

      unless override["type"].blank?
        recording.recording_type = RecordingType.find_or_create_by(name: override["type"])
      end

      unless override["date_override"].blank?
        recording.recorded_at = Date.parse override["date_override"]
      end

      recording.save
    end
  end
end
