class TagsController < ApplicationController
  def tag
    @show_tag = ShowTag.find_by(slug: params[:slug])

    @shows = Show.joins(:show_tags)
                 .where(show_tags: { slug: params[:slug] })
                 .distinct
                 .where(is_active: true)
                 .order(date: :desc)
  end
end
