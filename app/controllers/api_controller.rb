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
    show = Show.find_by(slug: params[:slug], is_active: true)

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
    #   "id": "2015-09-02kexp",
    #   "date": "2015-09-02",
    #   "order": 1,
    #   "poster_url": "https://kglw.net/i/poster-art-1678668055.png",
    #   "notes": "This was an in-studio appearance for radio station <a href=\" https://www.kexp.org/\" target=\"_blank\" rel=\"noreferrer\">KEXP</a> in Seattle. Following the performance Stu & Joey had an 8 minute interview with KEXP DJ <a href=\"https://en.wikipedia.org/wiki/Cheryl_Waters_(radio_personality)\" target=\"_blank\" rel=\"noreferrer\">Cheryl Waters</a>.",
    #   "title": "",
    #   "kglw_net": {
    #     "id": 1678668055,
    #     "permalink": "king-gizzard-the-lizard-wizard-september-2-2015-kexp-studios-seattle-wa-usa.html"
    #   },
    #   "venue_id": 332,
    #   "tour_id": 43,
    #   "recordings": [
    #     {
    #       "id": "kglw2015-09-02",
    #       "uploaded_at": "2022-09-04T21:02:07+00:00",
    #       "type": null,
    #       "source": null,
    #       "lineage": null,
    #       "taper": null,
    #       "files_path_prefix": "https://archive.org/download/kglw2015-09-02/",
    #       "internet_archive": {
    #         "is_lma": false
    #       },
    #       "files": [
    #         {
    #           "filename": "kglw2015-09-02t01.mp3",
    #           "length": 17.06,
    #           "title": "Intro"
    #         },
    #         {
    #           "filename": "kglw2015-09-02t02.mp3",
    #           "length": 583.18,
    #           "title": "The River"
    #         },
    #         {
    #           "filename": "kglw2015-09-02t03.mp3",
    #           "length": 202.9,
    #           "title": "I'm In Your Mind"
    #         },
    #         {
    #           "filename": "kglw2015-09-02t04.mp3",
    #           "length": 160.25,
    #           "title": "I'm Not In Your Mind"
    #         },
    #         {
    #           "filename": "kglw2015-09-02t05.mp3",
    #           "length": 164.69,
    #           "title": "Cellophane"
    #         },
    #         {
    #           "filename": "kglw2015-09-02t06.mp3",
    #           "length": 160.56,
    #           "title": "I'm In Your Mind Fuzz"
    #         },
    #         {
    #           "filename": "kglw2015-09-02t07.mp3",
    #           "length": 465.8,
    #           "title": "Interview"
    #         }
    #       ]
    #     }
    #   ]
    # }
  end
end
