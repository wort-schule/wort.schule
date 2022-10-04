import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  search() {
    this.element.requestSubmit()
  }
}
