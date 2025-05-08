class CreateRecordingTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :recording_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
