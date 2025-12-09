# README

A web app for streaming live music recordings. Rewrite of a previous version, now using Rails 8, Tailwind, Hotwire, etc.. Code licensed under AGPL. Currently hardcoded to cater for King Gizzard.

# Live instances

* [Gizz Tapes](https://tapes.kglw.net/) (soon!)
* [Gizz Tapes (dev)](https://gizztapes2.fly.dev/)

# Commands

## Running

Start with `foreman start -f Procfile.dev`

## Rake tasks

* `tapes:setShowColors` -- sets background colors for all shows based on posters
* `tapes:setDefaults` -- tries to match recordings to shows where possible, and pick a preferred recording format -- not necessary if purely mirroring from a live instance with `tapes:update`
* `tapes:update` -- fetches recordings settings from a live instance of the website
* `tapes:ia:loadOverrides["~/path"]` -- loads overrides from GT1
* `tapes:ia:update` -- refetches all recordings from the Internet Archive
* `tapes:ia:fetchNew` -- fetches new recordings from the Internet Archive
* `tapes:songfish:loadOverrides["~/path"]` -- loads overrides from GT1
* `tapes:songfish:update` -- fetches latest show, setlist, etc. data from a Songfish instance

### Rswag

* `rake rswag` -- update the API docs page based on `/spec/requests/api/api_spec.rb`

## Fly.io

* `fly deploy`
* `fly status`
* `fly ssh sftp shell`
* `fly ssh console`