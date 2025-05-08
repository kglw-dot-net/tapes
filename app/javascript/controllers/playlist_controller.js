import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.playlist = {
            // TODO: There's a stimulus way of doing this I'm sure
            id: this.element.dataset.playlistId,
            title: this.element.dataset.playlistTitle,
            thumbnail: this.element.dataset.playlistThumbnail,
            url: window.location.href,
            tracks: [...this.element.querySelectorAll(`[data-action="playlist#playTrack"]`)].map(track => ({
                url: decodeURIComponent(track.href),
                recordingUrl: track.dataset.recordingUrl,
                title: track.dataset.trackTitle
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
