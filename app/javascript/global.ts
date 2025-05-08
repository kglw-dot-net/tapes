import { Application } from "@hotwired/stimulus"

declare global {
    interface Window {
        Stimulus: Application,
        Turbo: any
    }
}