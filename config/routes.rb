require 'date'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Pages controller

  root "pages#home"

  get "about" => "pages#about"

  # Shows controller

  get "years" => "shows#years"

  years = Show.where(is_active: true).select("strftime('%Y', date) AS year").distinct.map(&:year)

  years.each do |year|
    get year.to_s => "shows#year", year: year
  end

  Show.where.not(slug: nil).where(is_active: true).each do |show|
    get show.slug => "shows#show", id: show.id
  end

  Date::MONTHNAMES.compact.each_with_index do |month, index|
    next unless Show.where(is_active: true)
      .where("strftime('%m', date) = ?", "%02d" % (index + 1))
      .exists?

    get month.downcase => "shows#month", month: index + 1

    # Get dates within this month for which there is an active show
    dates = Show.where(is_active: true)
      .where("strftime('%m', date) = ?", "%02d" % (index + 1))
      .select("strftime('%d', date) AS day")
      .distinct
      .map(&:day)

    dates.each do |day|
      get "#{month}/#{day}" => "shows#date", month: index + 1, date: day
    end
  end

  # Discography controller

  get "songs" => "discography#index"
  get "songs/:slug" => "discography#song", as: :song
end
