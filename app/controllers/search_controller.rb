class SearchController < ApplicationController
  def index
    @query = params[:q]&.strip
    @shows = Searcher.search(@query)
  end
end
