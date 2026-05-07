import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.load();
    }

    load() {
        const now = new Date();
        const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;

        const month = new Intl.DateTimeFormat("en-US", { month: 'long', timeZone: tz })
            .format(now)
            .toLowerCase();

        const day = now.getDate();

        fetch(`/today/${month}/${day}`)
            .then(response => response.text())
            .then(html => this.element.innerHTML = html);
    }
}