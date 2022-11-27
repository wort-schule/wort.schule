import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="confetti"
export default class extends Controller {
  connect() {
    const confettiClass = "bg-confetti-animated";
    const animationLengthInSeconds = 3;

    this.element.classList.add(confettiClass);

    setTimeout(
      () => this.element.classList.remove(confettiClass),
      animationLengthInSeconds * 1000
    );
  }
}
