class SettingsController < ApplicationController
  def index
    @recording_types = RecordingType
      .joins(recordings: :show)
      .where(recordings: { is_active: true, shows: { is_active: true } })
      .distinct
      .all

      @tapers = Taper
        .joins(recordings: :show)
        .where(recordings: { is_active: true, shows: { is_active: true } })
        .where.not(name: [ nil, "" ])
        .where.not("LOWER(name) LIKE ?", "%sam joseph%")
        .select("tapers.*, COUNT(*) AS recording_count")
        .group("tapers.id, tapers.name")
        .order("recording_count DESC")
        .having("COUNT(*) > 1")
  end
end
