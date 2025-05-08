require "internet_archive"
require "songfish"

namespace :tapes do
  desc "Set default values for shows & recordings"
  task setDefaults: [ :environment ] do
    include Tapes

    puts "Setting default values for shows & recordings..."

    Tapes.setDefaults

    puts "Done!"
  end

  desc "Set background colors for shows based on posters"
  task setShowColors: [ :environment ] do
    include Tapes

    puts "Setting background colors for shows based on posters..."

    Tapes.setShowColors

    puts "Done!"
  end

  namespace :internet_archive do
    desc "Pull the latest Internet Archive data"
    task update: [ :environment ] do
      include InternetArchive

      puts "Updating Internet Archive data..."

      InternetArchive.update

      puts "Done!"
    end

    desc "Load archive_overrides.yml file from GT1"
    task :loadOverrides, [ :path ] => [ :environment ] do |t, args|
      include InternetArchive

      puts "Loading archive_overrides.yml file from GT1..."

      InternetArchive.loadOverrides(args[:path])

      puts "Done!"
    end
  end

  namespace :songfish do
    desc "Pull the latest Songfish data"
    task update: [ :environment ] do
      include Songfish

      puts "Updating Songfish data..."

      Songfish.update

      puts "Done!"
    end

    desc "Load show_overrides.yml file from GT1"
    task :loadOverrides, [ :path ] => [ :environment ] do |t, args|
      include Songfish

      puts "Loading show_overrides.yml file from GT1..."

      Songfish.loadOverrides(args[:path])

      puts "Done!"
    end
  end
end
