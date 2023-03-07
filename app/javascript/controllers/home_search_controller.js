import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home-search"
export default class extends Controller {
  static targets = ["input"]

  static values = {
    path: String
  }

  connect() {
    this.currentResultPosition = -1
  }

  noop(event) {
    event.preventDefault()
  }

  input(event) {
    switch(event.key) {
      case "Enter":
        event.preventDefault()

        if(this.currentResultPosition >= 0) {
          this.goToActiveSearchResult()
        } else {
          this.goToSearchResults()
        }
        return
      case "ArrowDown":
        this.currentResultPosition += 1
        this.clampCurrentResultPosition()
        this.setActiveSearchResult()
        return
      case "ArrowUp":
        this.currentResultPosition -= 1
        this.clampCurrentResultPosition()
        this.setActiveSearchResult()
        return
    }

    event.target.form.requestSubmit()
  }

  goToSearchResults() {
    if (this.inputTarget.value.trim().length > 0) {
      window.location = `${this.pathValue}?filterrific[filter_home]=${this.inputTarget.value}`
    }
  }

  getSearchResults() {
    return this.element.querySelectorAll('[data-search-result]')
  }

  clampCurrentResultPosition() {
    const searchResultsCount = this.getSearchResults().length
    const current = this.currentResultPosition
    const min = -1
    const max = searchResultsCount - 1

    this.currentResultPosition = Math.min(Math.max(current, min), max)
  }

  setActiveSearchResult() {
    const searchResults = this.getSearchResults()

    searchResults.forEach(result => result.classList.remove('active'))

    if(this.currentResultPosition >= 0) {
      searchResults[this.currentResultPosition].classList.add('active')
    }
  }

  goToActiveSearchResult() {
    const searchResults = this.getSearchResults()

    Turbo.visit(searchResults[this.currentResultPosition].href)
  }
}
