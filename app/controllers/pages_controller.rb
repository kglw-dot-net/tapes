class PagesController < ApplicationController
  def home
    @shows_per_card = 6

    # Get the latest n shows
    @most_recent_shows = Show
      .where(is_active: true)
      .order(date: :desc, order: :desc)
      .limit(@shows_per_card)

    # Get n random shows
    # No real need to exclude posterless shows, just looks nicer on the front page
    # First impressions and all that
    @random_shows = Show
      .where(is_active: true)
      .where.not(poster_url: nil)
      .order(Arel.sql("RANDOM()"))
      .limit(@shows_per_card)

    # Get n shows from today's date
    # e.g. if today is 2024-12-26, get all shows with on December 26th regardless of year
    @today_shows = Show
      .where(is_active: true)
      # .where("EXTRACT(MONTH FROM date) = ? AND EXTRACT(DAY FROM date) = ?", Time.current.month, Time.current.day)
      .where("strftime('%m', date) = ? AND strftime('%d', date) = ?", Time.current.month.to_s.rjust(2, "0"), Time.current.day.to_s.rjust(2, "0"))
      .order(date: :desc, order: :desc)
      .limit(@shows_per_card)

    @latest_year = Show.where(is_active: true).maximum(:date).year
    @earliest_year = Show.where(is_active: true).minimum(:date).year

    @total_shows = Show.where(is_active: true).count

    @total_recordings = Recording.joins(:show)
      .where(is_active: true, shows: { is_active: true })
      .count

    total_minutes = RecordingFile.joins(recording: :show)
      .where("recording_files.name LIKE '%' || recordings.preferred_format")
      .where(recordings: { is_active: true, shows: { is_active: true } })
      .sum(:length) / 60

    @hours = ActiveSupport::NumberHelper.number_to_delimited((total_minutes / 60).floor)
    @minutes = ActiveSupport::NumberHelper.number_to_delimited((total_minutes % 60).floor)

    hero_photos = [    { url: "https://i.imgur.com/MxtbhSr.jpeg", vPosition: 42, credit: "Mason D, 2022-05-22 @ Millvale PA, USA" }, { url: "https://i.imgur.com/9ZkIXqu.jpeg", vPosition: 66, credit: "PurpleMoustache, 2022-10-15 @ Chicago IL, USA" }, { url: "https://i.imgur.com/zpHsooR.jpeg", vPosition: 80, credit: "TimelandIsWacky, 2022-10-15 @ Chicago IL, USA" }, { url: "https://i.imgur.com/McaDBtQ.jpeg", vPosition: 67, credit: "TimelandIsWacky, 2022-10-15 @ Chicago IL, USA" }, { url: "https://i.imgur.com/GdfqPya.jpeg", vPosition: 69, credit: "TimelandIsWacky, 2023-06-12 @ Chicago IL, USA" }, { url: "https://i.imgur.com/fdF9Eih.jpeg", vPosition: 65, credit: "TimelandIsWacky, 2023-06-12 @ Chicago IL, USA" }, { url: "https://i.imgur.com/Lcmqy3R.jpeg", vPosition: 80, credit: "TimelandIsWacky, 2023-06-13 @ Chicago IL, USA" }, { url: "https://i.imgur.com/7SeKDAf.jpeg", vPosition: 52, credit: "TimelandIsWacky, 2023-06-13 @ Chicago IL, USA" }, { url: "https://i.imgur.com/iitPRcK.jpeg", vPosition: 35, credit: "Jakov Šafran, 2023-08-22 @ Padua, IT" }, { url: "https://i.imgur.com/zYad5tv.jpg",  vPosition: 41, credit: "Jakov Šafran, 2023-08-22 @ Padua, IT" }, { url: "https://i.imgur.com/67r4c2o.jpeg", vPosition: 24, credit: "ToraTapes, 2024-05-22 @ Hamburg, DEU" }, { url: "https://i.imgur.com/EwOzwvQ.jpeg", vPosition: 30, credit: "ToraTapes, 2024-05-22 @ Hamburg, DEU" }, { url: "https://i.imgur.com/rZMIv1D.jpeg", vPosition: 79, credit: "ToraTapes, 2024-05-23 @ Amsterdam, NL" }, { url: "https://i.imgur.com/3GSPnAv.jpeg", vPosition: 44, credit: "ToraTapes, 2024-05-23 @ Amsterdam, NL" }, { url: "https://i.imgur.com/k5UuLsK.jpeg", vPosition: 69, credit: "ToraTapes, 2024-05-23 @ Amsterdam, NL" }, { url: "https://i.imgur.com/XAiaTWu.jpeg", vPosition: 36, credit: "Frytography3540, 2024-08-16 @ Queens NY, USA" }, { url: "https://i.imgur.com/vPTUIjH.jpeg", vPosition: 65, credit: "Shan Horan, 2024-08-19 @ Boston MA USA" }, { url: "https://i.imgur.com/co2LcZx.jpeg", vPosition: 55, credit: "Mark Davidson, 2024-08-20 @ Portland ME, USA" }, { url: "https://i.imgur.com/95r8DHS.jpeg", vPosition: 60, credit: "Mark Davidson, 2024-08-20 @ Portland ME, USA" }, { url: "https://i.imgur.com/mARaZSM.jpeg", vPosition: 72, credit: "Mark Davidson, 2024-08-20 @ Portland ME, USA" }, { url: "https://i.imgur.com/T72u04p.jpeg", vPosition: 40, credit: "Mark Davidson, 2024-08-20 @ Portland ME, USA" }, { url: "https://i.imgur.com/3LM4wSW.jpeg", vPosition: 23, credit: "David Avidan, 2024-08-27 @ Philadelphia PA, USA" }, { url: "https://i.imgur.com/702gWrN.jpeg", vPosition: 44, credit: "David Avidan, 2024-08-27 @ Philadelphia PA, USA" }, { url: "https://i.imgur.com/cZ7H1s4.jpeg", vPosition: 53, credit: "David Avidan, 2024-08-27 @ Philadelphia PA, USA" }, { url: "https://i.imgur.com/RPfFQnm.jpeg", vPosition: 20, credit: "David Avidan, 2024-08-27 @ Philadelphia PA, USA" }, { url: "https://i.imgur.com/sQKrODS.jpeg", vPosition: 55, credit: "Joe Lugo, 2024-08-27 @ Philadelphia PA, USA" }, { url: "https://i.imgur.com/D9qgiYX.jpeg", vPosition: 40, credit: "the.bread.photography, 2024-09-01 @ Chicago IL, USA" }, { url: "https://i.imgur.com/FprUDnN.jpeg", vPosition: 50, credit: "the.bread.photography, 2024-09-01 @ Chicago IL, USA" }, { url: "https://i.imgur.com/4GRF3Qw.jpeg", vPosition: 68, credit: "the.bread.photography, 2024-09-01 @ Chicago IL, USA" }, { url: "https://i.imgur.com/z4tBeEr.jpeg", vPosition: 70, credit: "the.bread.photography, 2024-09-01 @ Chicago IL, USA" }, { url: "https://i.imgur.com/r0XieGb.jpeg", vPosition: 53, credit: "lucid, 2024-09-09 @ Morrison CO, USA" }, { url: "https://i.imgur.com/Dlvl9z6.jpeg", vPosition: 50, credit: "Kevin Kenly, 2024-09-09 @ Red Rocks, USA" }, { url: "https://i.imgur.com/9nKT99B.jpeg", vPosition: 43, credit: "Bret Koons, 2024-09-09 @ Red Rocks, USA" }, { url: "https://i.imgur.com/qk4PHM2.jpeg", vPosition: 30, credit: "Theo Bahner, 2024-09-24 @ The Gorge, USA" }, { url: "https://i.imgur.com/khDmosK.jpeg", vPosition: 64, credit: "Theo Bahner, 2024-09-24 @ The Gorge, USA" }, { url: "https://i.imgur.com/JYiu7TH.jpeg", vPosition: 33, credit: "Axe, 2024-11-03 @ Paso Robles CA, USA" }, { url: "https://i.imgur.com/K2aNZr1.jpeg", vPosition: 70, credit: "Axe, 2024-11-03 @ Paso Robles CA, USA" }, { url: "https://i.imgur.com/PD3UNxn.jpeg", vPosition: 40, credit: "Axe, 2024-11-04 @ Stanford CA, USA" }, { url: "https://i.imgur.com/LLXzXWk.jpeg", vPosition: 60, credit: "Axe, 2024-11-04 @ Stanford CA, USA" }, { url: "https://i.imgur.com/lIxdgPN.jpeg", vPosition: 20, credit: "/u/roadhogmtn, 2024-11-10 @ Albuquerque NM, USA" } ]

    @hero_photo = hero_photos.sample

    @sbd_count = Recording.joins(:recording_type, :show)
      .where(is_active: true, recording_types: { name: "SBD" }, shows: { is_active: true })
      .count

    @aud_count = Recording.joins(:recording_type, :show)
      .where(is_active: true, recording_types: { name: "AUD" }, shows: { is_active: true })
      .count
  end

  def about
  end
end
