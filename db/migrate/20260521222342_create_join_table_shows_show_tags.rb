class CreateJoinTableShowsShowTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :shows, :show_tags do |t|
      # t.index [:show_id, :show_tag_id]
      # t.index [:show_tag_id, :show_id]
    end
  end
end
