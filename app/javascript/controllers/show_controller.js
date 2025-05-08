import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['recording']

    connect() {
        if (this.hasRecordingTarget)
            this.recordingTarget.value = this.selectRecordingFromPreferences();

        // TODO: If currently playing, show the currently playing recording
        this.showRecording(this.hasRecordingTarget ? this.recordingTarget.value : this.element.querySelector('[data-controller="playlist"]').dataset.playlistId);
    }

    selectRecordingFromPreferences() {
        let settings = JSON.parse(localStorage.getItem('settings')) || { };

        settings.prefRecTypes = settings.prefRecTypes || ["SBD", "MTX", "AUD", "Mixed"];
        settings.favouriteTapers = settings.favouriteTapers || [];
        
        let availableRecordings = [...this.recordingTarget.options]
            .map((option) => ({ id: option.value, taper: option.dataset.taper, type: option.dataset.type }))
            .sort((a, b) => {
                let aRecType = settings.prefRecTypes.indexOf(a.type);
                let bRecType = settings.prefRecTypes.indexOf(b.type);
    
                if (aRecType !== bRecType)
                    return Math.sign(aRecType - bRecType);
    
                let aFav = settings.favouriteTapers.includes(a.taper) ? 0 : 1;
                let bFav = settings.favouriteTapers.includes(b.taper) ? 0 : 1;
    
                return Math.sign(aFav - bFav);
            });

        return availableRecordings[0].id;
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
