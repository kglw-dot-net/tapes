class MakeContinentNullableOnCountries < ActiveRecord::Migration[8.0]
  def change
    change_column_null :countries, :continent_id, true
  end
end
