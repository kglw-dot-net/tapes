class ShowsController < ApplicationController
  # GET /years
  def years
    @years = Show
      .select("strftime('%Y', date) AS year, COUNT(*) AS show_count, MAX(CASE WHEN poster_url IS NOT NULL THEN poster_url ELSE '' END) AS poster_url")
      .where(is_active: true)
      .group("year")
      .order(year: :desc)
  end

  # GET /:year
  def year
    @year = params[:year]

    @years = Show.where(is_active: true).select("strftime('%Y', date) AS year").distinct.map(&:year)

    @shows = Show
      .where(is_active: true)
      .where("date >= ? AND date <= ?", "#{@year}-01-01", "#{@year}-12-31")
      .distinct

    @tours = Tour
      .joins(:shows)
      .where(id: @shows.select(:tour_id).distinct)
      .select("tours.*, MAX(shows.date) AS max_show_date")
      .group("tours.id")
      .order("max_show_date DESC")
  end

  # GET /:slug
  def show
    @show = Show.find_by(slug: params[:slug])

    if @show.nil?
      raise ActionController::RoutingError.new("Not Found")
    end
  end

  # GET /:month
  def month
    @month_name = params[:month]

    @month = Date::MONTHNAMES.compact.index { |m| m.casecmp(@month_name) == 0 } + 1

    @dates = Show.where(is_active: true)
      .where("strftime('%m', date) = ?", "%02d" % @month)
      .select("ltrim(strftime('%e', date)) AS day")
      .distinct
      .map(&:day)
  end

  # GET /:month/:date
  def date
    @month = params[:month]
    @date = params[:date]
  end
end
