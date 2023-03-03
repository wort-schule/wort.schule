import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home-search"
export default class extends Controller {
  static targets = ["input"]

  static values = {
    path: String
  }

  input(event) {
    if (event.key === 'Enter') {
      this.goToSearchResults()
    }
  }

  goToSearchResults() {
    if (this.inputTarget.value.trim().length > 0) {
      window.location = `${this.pathValue}?filterrific[filter_home]=${this.inputTarget.value}`
    }
  }
}
