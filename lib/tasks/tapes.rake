require "internet_archive"
require "songfish"

namespace :tapes do
  desc "Set default values for shows & recordings"
  task setDefaults: [ :environment ] do
    puts "Setting default values for shows & recordings..."

    Tapes.setDefaults

    puts "Clearing caches..."

    Rails.cache.clear

    puts "Done!"
  end

  desc "Manually update weighted show ratings"
  task calculateWeightedRatings: [ :environment ] do
    puts "Calculating weighted show ratings..."

    Tapes.calculateWeightedRatings

    puts "Done!"
  end

  desc "Set background colors for shows based on posters"
  task setShowColors: [ :environment ] do
    puts "Setting background colors for shows based on posters..."

    Tapes.setShowColors

    puts "Done!"
  end

  desc "Import GT1 albums list"
  task :importAlbums, [ :path ] => [ :environment ] do |t, args|
    puts "Importing GT1 albums list..."

    Tapes.importAlbums(args[:path])

    puts "Done!"
  end

  namespace :ia do
    desc "Fetch the latest Internet Archive uploads"
    task fetchNew: [ :environment ] do
      puts "Fetching new Internet Archive uploads..."

      InternetArchive.update(true)

      puts "Done!"
    end

    desc "Update all Internet Archive data"
    task update: [ :environment ] do
      puts "Updating all Internet Archive data..."

      InternetArchive.update(false)

      puts "Done!"
    end

    desc "Load archive_overrides.yml file from GT1"
    task :loadOverrides, [ :path ] => [ :environment ] do |t, args|
      puts "Loading archive_overrides.yml file from GT1..."

      InternetArchive.loadOverrides(args[:path])

      puts "Done!"
    end
  end

  namespace :songfish do
    desc "Pull the latest Songfish data"
    task update: [ :environment ] do
      puts "Updating Songfish data..."

      Songfish.update

      puts "Done!"
    end

    desc "Full Songfish update, using web scraper to update ratings and posters"
    task fullUpdate: [ :environment ] do
      puts "Updating Songfish data..."

      Songfish.full_update

      puts "Done!"
    end

    desc "Load show_overrides.yml file from GT1"
    task :loadOverrides, [ :path ] => [ :environment ] do |t, args|
      puts "Loading show_overrides.yml file from GT1..."

      Songfish.loadOverrides(args[:path])

      puts "Done!"
    end
  end
end
