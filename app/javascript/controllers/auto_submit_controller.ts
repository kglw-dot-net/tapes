import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	static targets = ["input", "form"];
	
	declare readonly formTarget: HTMLFormElement;
	
	timeout: NodeJS.Timeout | null = null;
	
	connect() {
		this.timeout = null;
	}
	
	submitForm() {
		this.formTarget.requestSubmit();
	}
	
	input() {
		clearTimeout(this.timeout);
		this.timeout = setTimeout(() => this.submitForm(), 500);
	}
	
	blur() {
		clearTimeout(this.timeout);
		this.submitForm();
	}
}