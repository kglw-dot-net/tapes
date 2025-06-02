class TypesController < ApplicationController
  def type
    @set_type = SetType.find_by_sql([
                                      "SELECT * FROM set_types WHERE LOWER(REPLACE(name, ' ', '-')) = ? LIMIT 1",
                                      params[:slug].downcase
                                    ]).first

    @shows = Show.joins(:setlists)
                 .where(setlists: { set_type_id: @set_type.id })
                 .distinct
                 .where(is_active: true)
                 .order(date: :desc)
  end
end
