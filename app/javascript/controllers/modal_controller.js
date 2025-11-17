import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "content"]

  open(event) {
    event.preventDefault()
    const errorContent = event.currentTarget.dataset.errorContent
    this.contentTarget.textContent = errorContent
    this.containerTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.containerTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  closeOnBackdrop(event) {
    if (event.target === this.containerTarget) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  connect() {
    document.addEventListener("keydown", this.closeOnEscape.bind(this))
  }

  disconnect() {
    document.removeEventListener("keydown", this.closeOnEscape.bind(this))
  }
}
