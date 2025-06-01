class CreateYearThumbnails < ActiveRecord::Migration[8.0]
  def change
    create_table :year_thumbnails do |t|
      t.integer :year
      t.string :poster_url

      t.timestamps
    end
  end
end
