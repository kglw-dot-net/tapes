require 'swagger_helper'

RSpec.describe 'API', type: :request do
  path '/api/v1/shows.json' do
    get 'Retrieves all shows' do
      tags 'Shows'
      produces 'application/json'

      response '200', 'shows found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :string },
                   date: { type: :string },
                   venuename: { type: :string },
                   location: { type: :string },
                   title: { type: :string },
                   order: { type: :integer },
                   poster_url: { type: :string },
                   average_rating: { type: :number, format: :float },
                   count_ratings: { type: :integer },
                   weighted_rating: { type: :number, format: :float }
                 },
                 required: %w[id date venuename location order]
               }

        run_test!
      end
    end
  end

  path '/api/v1/shows/{id}.json' do
    get 'Retrieves a show' do
      tags 'Shows'
      produces 'application/json'

      parameter name: :id, in: :path, type: :string

      response '200', 'show found' do
        schema type: :object,
               properties: {
                 id: { type: :string },
                 date: { type: :string },
                 order: { type: :integer },
                 poster_url: { type: :string },
                 notes: { type: :string },
                 title: { type: :string },
                 average_rating: { type: :number, format: :float },
                 count_ratings: { type: :integer },
                 weighted_rating: { type: :number, format: :float },
                 kglw_net: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     permalink: { type: :string }
                   },
                   required: %w[id permalink]
                 },
                 venue_id: { type: :string },
                 tour_id: { type: :string },
                 sets: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       number: { type: :integer },
                       set_type: { type: :string },
                       set_type_id: { type: :integer },
                       songs: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             song: {
                               type: :object,
                               properties: {
                                 id: { type: :integer },
                                 slug: { type: :string },
                                 name: { type: :string }
                               },
                               required: %w[id slug name]
                             },
                             position: { type: :integer },
                             duration: { type: :integer },
                             footnote: { type: :string },
                             is_notable: { type: :boolean },
                             notable_description: { type: :string },
                             transition: { type: :string }
                           },
                           required: %w[song position duration is_notable]
                         }
                       }
                     },
                     required: %w[number set_type songs]
                   }
                 },
                 recordings: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       uploaded_at: { type: :string },
                       type: { type: :string },
                       source: { type: :string },
                       lineage: { type: :string },
                       taper: { type: :string },
                       files_path_prefix: { type: :string },
                       internet_archive: {
                         type: :object,
                         properties: {
                           is_lma: { type: :boolean }
                         },
                         required: %w[is_lma]
                       },
                       files: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             filename: { type: :string },
                             length: { type: :integer },
                             title: { type: :string }
                           },
                           required: %w[filename length]
                         }
                       }
                     },
                     required: %w[id files_path_prefix files]
                   }
                 }
               },
               required: %w[id date order recordings sets]

        let(:id) { Show.where(is_active: true).order(date: :desc).first.slug }

        run_test!
      end

      response '404', 'show not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/hero_photos.json' do
    get 'Retrieves hero photos' do
      tags 'Misc.'

      produces 'application/json'

      response '200', 'hero photos found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   credit: { type: :string },
                   vPosition: { type: :integer },
                   url: { type: :string }
                 },
                 required: %w[credit url]
               }

        run_test!
      end
    end
  end

  path '/api/v1/search' do
    get 'Searches all shows' do
      tags 'Shows'
      produces 'application/json'

      parameter name: :q, in: :query, type: :string
      parameter name: :set_type_id,
                in: :query,
                type: :array,
                items: { type: :integer },
                collectionFormat: :multi

      response '200', 'shows found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :string },
                   date: { type: :string },
                   venuename: { type: :string },
                   location: { type: :string },
                   title: { type: :string },
                   order: { type: :integer },
                   poster_url: { type: :string },
                   average_rating: { type: :number, format: :float },
                   count_ratings: { type: :integer },
                   weighted_rating: { type: :number, format: :float }
                 },
                 required: %w[id date venuename location order]
               }

        run_test!
      end
    end
  end

  path '/api/v1/years.json' do
    get 'List all years with shows' do
      tags 'Misc.'

      produces 'application/json'

      response '200', 'years found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   year: { type: :integer },
                   show_count: { type: :integer },
                   poster_url: { type: :string }
                 },
                 required: %w[year show_count]
               }

        run_test!
      end
    end
  end

  path '/api/v1/stats.json' do
    get 'Retrieves statistics' do
      tags 'Misc.'

      produces 'application/json'

      response '200', 'stats found' do
        schema type: :object,
               properties: {
                 latest_year: { type: :integer },
                 earliest_year: { type: :integer },
                 total_shows: { type: :integer },
                 total_recordings: { type: :integer },
                 hours: { type: :integer },
                 minutes: { type: :integer },
                 sbd_count: { type: :integer },
                 aud_count: { type: :integer }
               },
               required: %w[latest_year earliest_year total_shows total_recordings hours minutes sbd_count aud_count]

        run_test!
      end
    end
  end

  path '/api/v1/venues.json' do
    get 'Retrieves venues' do
      tags 'Venues'

      produces 'application/json'

      response '200', 'venues found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   slug: { type: :string },
                   name: { type: :string },
                   city: { type: :string },
                   region: { type: :string },
                   country_id: { type: :integer },
                   show_count: { type: :integer }
                 },
                 required: %w[id name show_count]
               }

        run_test!
      end
    end
  end

  path '/api/v1/countries.json' do
    get 'Retrieves countries' do
      tags 'Venues'

      produces 'application/json'

      response '200', 'countries found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   show_count: { type: :integer }
                 },
                 required: %w[id name show_count]
               }

        run_test!
      end
    end
  end

  path '/api/v1/songs.json' do
    get 'Retrieves songs' do
      tags 'Discography'

      produces 'application/json'

      response '200', 'songs found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   slug: { type: :string },
                   name: { type: :string },
                   album_id: { type: :integer },
                   track_number: { type: :integer },
                   show_count: { type: :integer }
                 },
                 required: %w[id name show_count]
               }

        run_test!
      end
    end
  end

  path '/api/v1/songs/{slug}.json' do
    get 'Retrieves a song' do
      tags 'Discography'

      produces 'application/json'

      parameter name: :slug, in: :path, type: :string

      response '200', 'song found' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 slug: { type: :string },
                 name: { type: :string },
                 album_id: { type: :integer },
                 track_number: { type: :integer },
                 shows: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       is_notable: { type: :boolean },
                       notable_description: { type: :string }
                     }
                   }
                 }
               },
               required: %w[id name show_count]

        let(:slug) { Song.first.slug }

        run_test!
      end

      response '404', 'song not found' do
        let(:slug) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/albums.json' do
    get 'Retrieves albums' do
      tags 'Discography'

      produces 'application/json'

      response '200', 'albums found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   title: { type: :string },
                   cover_art_url: { type: :string },
                   subtitle: { type: :string },
                   release_date: { type: :string }
                 },
                 required: %w[id title]
               }

        run_test!
      end
    end
  end

  path '/api/v1/set_types.json' do
    get 'Retrieves set types' do
      tags 'Misc.'

      produces 'application/json'

      response '200', 'set types found' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   show_count: { type: :integer }
                 },
                 required: %w[id name show_count]
               }

        run_test!
      end
    end
  end
end
