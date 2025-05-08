# README

A web app for streaming live music recordings. Rewrite of a previous version, now using Rails 8, Tailwind, Hotwire, etc.. Code licensed under AGPL. Currently hardcoded to cater for King Gizzard.

## Running

Start with `foreman start -f Procfile.dev`

## Live instances

* [Gizz Tapes](https://tapes.kglw.net/)

## Rake tasks

* `tapes:setShowColors` -- sets background colors for all shows based on posters
* `tapes:setDefaults` -- tries to match recordings to shows where possible, and pick a preferred recording format -- not necessary if purely mirroring from a live instance with `tapes:update`
* `tapes:update` -- fetches recordings settings from a live instance of the website
* `tapes:internet_archive:loadOverrides["~/path"]` -- loads overrides from GT1
* `tapes:internet_archive:update` -- fetches latest recordings from the Internet Archive
* `tapes:songfish:loadOverrides["~/path"]` -- loads overrides from GT1
* `tapes:songfish:update` -- fetches latest show, setlist, etc. data from a Songfish instance