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

  get ":year" => "shows#year", constraints: lambda { |request|
    Show.where(is_active: true).select("strftime('%Y', date) AS year").distinct.map(&:year).include?(request.params[:year])
  }

  get ":slug" => "shows#show", constraints: lambda { |request|
    Show.where.not(slug: nil).where(is_active: true).pluck(:slug).include?(request.params[:slug])
  }

  Date::MONTHNAMES.compact.each_with_index do |month, index|
    get ":month" => "shows#month", constraints: lambda { |request|
      index = Date::MONTHNAMES.compact.index { |m| m.casecmp(request.params[:month]) == 0 }

      index.present? &&
      Show.where(is_active: true)
        .where("strftime('%m', date) = ?", "%02d" % (index + 1))
        .exists?
    }

    get ":month/:date" => "shows#date", constraints: lambda { |request|
      index = Date::MONTHNAMES.compact.index { |m| m.casecmp(request.params[:month]) == 0 }

      index.present? &&
      Show.where(is_active: true)
        .where("strftime('%m', date) = ?", "%02d" % (index + 1))
        .where("strftime('%d', date) = ?", "%02d" % request.params[:date])
        .exists?
    }
  end

  # Discography controller

  get "songs" => "discography#index"
  get "songs/:slug" => "discography#song", as: :song
end
