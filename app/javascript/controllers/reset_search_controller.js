import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reset-search"
export default class extends Controller {
  connect() {
    const urlParams = new URLSearchParams(window.location.search);
    const query = urlParams.get('filterrific[filter_home]')
    this.element.value = query
  }
}
