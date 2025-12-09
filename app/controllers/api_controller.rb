class ApiController < ApplicationController
  def shows
    shows = Show
      .where(is_active: true)
      .map do |show|
        {
          id: show.slug,
          date: show.date,
          venuename: show.venue.name,
          location: [ show.venue.city, show.venue.region, show.venue.country&.name ].reject { |s| s.blank? }.join(", "),
          title: show.title,
          order: show.order,
          poster_url: show.poster_url
        }
      end

    render json: shows
  end

  def show
    show = Show.find_by(slug: params[:id], is_active: true) ||
           Show.find_by(songfishID: params[:id], is_active: true)

    raise ActionController::RoutingError.new("Not Found") if show.nil?

    render json: {
      id: show.slug,
      date: show.date,
      order: show.order,
      poster_url: show.poster_url,
      notes: show.notes,
      title: show.title,

      kglw_net: {
        id: show.songfishID,
        permalink: show.songfishPermalink
      },

      venue_id: show.venue_id,
      tour_id: show.tour_id,

      recordings: show.recordings.where(is_active: true).map do |recording|
        {
          id: recording.id,
          uploaded_at: recording.uploaded_at,
          type: recording.recording_type&.name,
          source: recording.source,
          lineage: recording.lineage,
          taper: recording.taper&.name,
          files_path_prefix: "https://archive.org/download/" + recording.id + "/",

          internet_archive: {
            is_lma: recording.is_lma
          },

          files: recording.recording_files.where("name LIKE :ext", ext: "%#{recording.preferred_format}").map do |file|
            {
              filename: file.name,
              length: file.length,
              title: file.title
            }
          end
        }
      end
    }
  end
end
