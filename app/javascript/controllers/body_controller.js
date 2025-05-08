import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        const settings = JSON.parse(localStorage.getItem('settings')) || {};
        const theme = settings.theme || 'auto';

        this.setTheme(theme);
    }

    setTheme(theme) {
        const body = document.querySelector('body');

        if (theme == 'auto')
            body.removeAttribute('data-theme');
        else
            body.setAttribute('data-theme', theme);
    }
}