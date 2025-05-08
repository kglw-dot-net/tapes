import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['recording']

    connect() {
        this.showRecording(this.hasRecordingTarget ? this.recordingTarget.value : this.element.querySelector('[data-controller="playlist"]').dataset.playlistId);
    }

    selectRecording() {
        this.showRecording(this.recordingTarget.value);
    }

    playFullShow() {
        if (this.hasRecordingTarget) {
            const recordingId = this.recordingTarget.value;
            this.element.querySelector(`[data-controller="playlist"][data-playlist-id="${recordingId}"] .track`).click();
            return;
        }

        this.element.querySelector(`[data-controller="playlist"] .track`).click();
    }

    showRecording(recordingId) {
        [...this.element.querySelectorAll('[data-controller="playlist"]')].forEach(playlistElement => {
            playlistElement.classList.add('hidden');
        });

        this.element.querySelector(`[data-controller="playlist"][data-playlist-id="${recordingId}"]`).classList.remove('hidden');
    }
}
