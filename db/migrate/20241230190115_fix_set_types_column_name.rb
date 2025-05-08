class FixSetTypesColumnName < ActiveRecord::Migration[8.0]
  def change
    rename_column :set_types, :separator, :name
  end
end
