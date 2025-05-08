import { Controller } from "@hotwired/stimulus"

export default class JumpToAnchorController extends Controller<HTMLElement> {
    static targets = ['source'];

    declare readonly sourceTarget: HTMLSelectElement;

    jump() {
        const anchor = this.sourceTarget.value;
        const target: HTMLElement = document.querySelector(`#${anchor}`);

        if (target == null) return;

        window.scrollTo({
            top: target.offsetTop - 20,
            behavior: "smooth"
        });
    }
}