# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "howler" # @2.2.4
pin "stimulus-use" # @0.52.3
pin "sortablejs" # @1.15.6
pin "dexie" # @2.0.4
pin "dexie-relationships" # @1.2.11
pin "process" # @2.1.0
