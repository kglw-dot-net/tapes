import { Controller } from "@hotwired/stimulus"
import Sortable from 'sortablejs';

export default class extends Controller {
    static targets = ['rankedRecordingTypes', 'isRankedRecordingTypes', 'favouriteTapers', 'theme']

    declare readonly rankedRecordingTypesTarget: HTMLElement;
    declare readonly isRankedRecordingTypesTarget: HTMLInputElement;
    declare readonly favouriteTapersTarget: HTMLElement;
    declare readonly themeTarget: HTMLSelectElement;

    initialize() {
        // In case Turbo ignores the cache ignoring setting, which it is wont to do
        this.element.setAttribute('busy', '');

        const settings = this.loadSettings();

        // this.themeTarget.value = settings.theme || 'auto';

        this.isRankedRecordingTypesTarget.checked = !!settings.prefRecTypes;

        this.showHideRecordingTypesRanking();

        let sortable = new Sortable(this.rankedRecordingTypesTarget,
            {
                scroll: false,
                onEnd: this.saveRecordingTypesRanking.bind(this)
            });

        if (settings.prefRecTypes)
			sortable.sort(settings.prefRecTypes);

        this.favouriteTapersTarget.querySelectorAll('input').forEach((input) => {
            input.checked = settings.favouriteTapers?.includes(input.value);
        });

        this.element.removeAttribute('busy');
    }

    loadSettings() {
        return JSON.parse(localStorage.getItem('settings')) || {};
    }

    showHideRecordingTypesRanking() {
        const isRankedRecordingTypes = this.isRankedRecordingTypesTarget.checked;

        if (isRankedRecordingTypes) {
            this.rankedRecordingTypesTarget.classList.remove('hidden');
            this.rankedRecordingTypesTarget.classList.remove('opacity-0');
            return;
        }

        this.rankedRecordingTypesTarget.classList.add('hidden');
        this.rankedRecordingTypesTarget.classList.add('opacity-0');
    }

    toggleRecordingTypesRanking() {
        this.showHideRecordingTypesRanking();
        this.saveRecordingTypesRanking();
    }

    getPreferredRecordingTypes() {
        return [...this.rankedRecordingTypesTarget.querySelectorAll('a')].map((a) => a.dataset.id);
    }

    saveRecordingTypesRanking() {
        const isRankedRecordingTypes = this.isRankedRecordingTypesTarget.checked;

        const prefRecTypes = isRankedRecordingTypes ? this.getPreferredRecordingTypes() : null;

        this.saveSettings({ prefRecTypes });
    }

    toggleFavouriteTaper() {
        const favouriteTapers = [...this.favouriteTapersTarget.querySelectorAll('input:checked')].map((input: HTMLInputElement) => input.value);
        

        this.saveSettings({ favouriteTapers });
    }

    // changeTheme() {
    //     const theme = this.themeTarget.value;

    //     this.saveSettings({ theme });

    //     // Call setTheme on the body controller
    //     const bodyController = this.application.getControllerForElementAndIdentifier(document.querySelector('body'), 'body');
    //     bodyController.setTheme(theme);
    // }

    saveSettings(newSettings) { 
        let existingSettings = this.loadSettings();

        const settings = { ...existingSettings, ...newSettings };

        localStorage.setItem('settings', JSON.stringify(settings));
    }
}
