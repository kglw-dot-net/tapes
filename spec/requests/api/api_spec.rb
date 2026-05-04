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
              poster_url: { type: :string }
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
          required: %w[id date order recordings]

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
                   poster_url: { type: :string }
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
end
