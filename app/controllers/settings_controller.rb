class SettingsController < ApplicationController
  def index
    @recording_types = RecordingType
                         .joins(recordings: :show)
                         .where(recordings: { is_active: true, shows: { is_active: true } })
                         .distinct
                         .all

    @tapers = Taper
                .joins("LEFT JOIN tapers children ON children.parent_id = tapers.id")
                .joins("LEFT JOIN recordings ON recordings.taper_id = tapers.id OR recordings.taper_id = children.id")
                .joins("INNER JOIN shows ON recordings.show_id = shows.id")
                .where(tapers: { parent_id: nil })
                .where(recordings: { is_active: true }, shows: { is_active: true })
                .where.not(tapers: { name: [ nil, "" ] })
                .where.not("LOWER(tapers.name) LIKE ?", "%sam joseph%")
                .where.not(tapers: { is_anon: true })
                .select("tapers.*, COUNT(recordings.id) AS recording_count")
                .group("tapers.id, tapers.name")
                .having("COUNT(recordings.id) > 2")
                .order("recording_count DESC")
  end
end
