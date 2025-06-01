class ShowsController < ApplicationController
  # GET /years
  def years
    @years = Show
               .select(<<~SQL)
    strftime('%Y', shows.date) AS year,
    COUNT(*) AS show_count,
    COALESCE(
      (SELECT yt.poster_url FROM year_thumbnails yt WHERE yt.year = strftime('%Y', shows.date) LIMIT 1),
      MAX(CASE WHEN shows.poster_url IS NOT NULL THEN shows.poster_url ELSE '' END)
    ) AS poster_url
  SQL
               .where(is_active: true)
               .group("year")
               .order("year DESC")
  end

  # GET /:year
  def year
    @year = params[:year]

    @years = Show.where(is_active: true).select("strftime('%Y', date) AS year").distinct.map(&:year)

    all_shows = Show
      .where(is_active: true)
      .where("date >= ? AND date <= ?", "#{@year}-01-01", "#{@year}-12-31")

    @shows = all_shows
      .includes(venue: :country)
      # .joins(:recordings)
      # .select("shows.*, COUNT(recordings.id) AS recording_count")
      .distinct

    @tours = Tour
      .joins(:shows)
      .where("shows.id IN (?)", all_shows.pluck(:id))
      .select("tours.*, MAX(shows.date) AS max_show_date")
      .group("tours.id")
      .order("max_show_date DESC")

    # @tours.each do |tour|
    #   puts "#{tour.name} - #{tour.max_show_date}"
    # end
  end

  # GET /:slug
  def show
    @show = Show.find_by(slug: params[:slug], is_active: true)

    raise ActionController::RoutingError.new("Not Found") if @show.nil?

    @total_seconds = @show.setlists
      .joins(:set_songs)
      .sum(:duration)

    @hours = (@total_seconds / 3600).floor
    @minutes = ((@total_seconds % 3600) / 60).floor

    @songs = @show.setlists
      .joins(:set_songs)
      .pluck(:song_id)
      .count
  end

  # GET /:month
  def month
    @month_name = params[:month]

    @months = Date::MONTHNAMES.compact

    @month = Date::MONTHNAMES.compact.index { |m| m.casecmp(@month_name) == 0 } + 1

    @days = Show.where(is_active: true)
      .where("strftime('%m', date) = ?", "%02d" % @month)
      .select("cast(strftime('%e', date) as int) AS day, COUNT(*) AS show_count")
      .group("day")
  end

  # GET /:month/:date
  def date
    @month_name = params[:month]

    @months = Date::MONTHNAMES.compact

    @month = Date::MONTHNAMES.compact.index { |m| m.casecmp(@month_name) == 0 } + 1

    @days = Show
      .where(is_active: true)
      .where("strftime('%m', date) = ?", "%02d" % @month)
      .select("cast(strftime('%e', date) as int) AS day")
      .distinct
      .map(&:day)
      .sort!

    @date = params[:date]

    @shows = Show
      .includes(venue: :country)
      .includes(:recordings)
      .where(is_active: true)
      .where("strftime('%m', date) = ?", "%02d" % @month)
      .where("strftime('%d', date) = ?", "%02d" % @date)
      .order(date: :desc)
  end

  # GET /:slug/partials/featured
  def featured
    @show = Show.find_by(slug: params[:slug], is_active: true)

    raise ActionController::RoutingError.new("Not Found") if @show.nil?

    respond_to do |format|
      format.turbo_stream {
         render turbo_stream: turbo_stream.append(
          "favourites-grid",
          partial: "featured_show",
          locals: { show: @show }
        )
      }
    end
  end
end
