import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.element.querySelector('[data-controller="playlist"]').classList.remove('hidden');
    }

    selectRecording(e) {
        [...this.element.querySelectorAll('[data-controller="playlist"]')].forEach(playlistElement => {
            playlistElement.classList.add('hidden');
        });

        const recordingId = e.currentTarget.value;

        this.element.querySelector(`[data-controller="playlist"][data-playlist-id="${recordingId}"]`).classList.remove('hidden');
    }
}
