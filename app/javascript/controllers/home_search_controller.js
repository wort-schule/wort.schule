import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home-search"
export default class extends Controller {
  static targets = [
    "input",
    "logo"
  ]

  static values = {
    path: String
  }

  connect() {
    this.updateLogoVisibility(false)
  }

  input(event) {
    if (event.key === 'Enter') {
      this.goToSearchResults()
      return
    }

    this.updateLogoVisibility(true)
  }

  updateLogoVisibility(reposition) {
    if(window.innerWidth > 768) return

    var hasQuery = this.inputTarget.value.length > 0
    this.logoTarget.style.display = hasQuery ? 'none' : 'block'
    if(reposition) this.inputTarget.scrollIntoView()
  }

  goToSearchResults() {
    window.location = `${this.pathValue}?filterrific[filter_home]=${this.inputTarget.value}`
  }
}
