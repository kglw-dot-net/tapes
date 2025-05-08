import { Controller } from "@hotwired/stimulus"
import { Playlist } from "../interfaces"

export default class extends Controller<HTMLElement> {
    declare playlist: Playlist;

    connect() {
        this.playlist = {
            // TODO: There's a stimulus way of doing this I'm sure
            id: this.element.dataset.playlistId,
            title: this.element.dataset.playlistTitle,
            thumbnail: this.element.dataset.playlistThumbnail,
            url: window.location.href,
            tracks: [...this.element.querySelectorAll(`[data-action="playlist#playTrack"]`)].map((track: HTMLAnchorElement) => ({
                title: track.dataset.trackTitle,
                
                url: decodeURIComponent(track.href),
                recordingUrl: track.dataset.recordingUrl,

                howl: null,
                duration: null
            }))
        };
    }

    playTrack(event) {
        event.preventDefault();

        const currentTrackUrl = decodeURIComponent(event.currentTarget.href);
        const trackIdx = this.playlist.tracks.findIndex(track => track.url === currentTrackUrl);

        this.dispatch("playTrack", { detail:{ playlist: this.playlist, trackIdx }});
    }
}
