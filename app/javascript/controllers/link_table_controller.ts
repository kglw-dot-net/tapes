import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    navigate(event) {
        (window as any).Turbo.visit(event.params.url);
    }
}