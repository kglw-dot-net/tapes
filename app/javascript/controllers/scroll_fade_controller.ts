import { Controller } from "@hotwired/stimulus"

export default class ScrollFadeController extends Controller<HTMLElement> {
    connect() {
        this.update();
        this.element.addEventListener("scroll", this.update);
    }

    disconnect() {
        this.element.removeEventListener("scroll", this.update);
    }

    update = () => {
        const scrollDistance = 80;
        const percentToCover = 4;

        const maxScroll = this.element.scrollWidth - this.element.clientWidth;

        if (maxScroll <= 0) {
            this.element.style.maskImage = "none";
            return;
        }

        const leftOpacity = Math.min(this.element.scrollLeft / scrollDistance, 1);
        const rightOpacity = Math.min((maxScroll - this.element.scrollLeft) / scrollDistance, 1);

        this.element.style.maskImage =
            `linear-gradient(
                to right, 
                transparent, 
                black ${percentToCover*leftOpacity}%, 
                black ${100-(percentToCover*rightOpacity)}%, 
                transparent
            )`;
    }
}