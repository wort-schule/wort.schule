import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="medium"
export default class extends Controller {
  static targets = ['mediaElement']

  connect() {
    this.reRenderMediaElement()
  }

  reRenderMediaElement () {
    const mediaElement = this.mediaElementTarget
    const clone = mediaElement.cloneNode(true)
    mediaElement.parentNode.insertBefore(clone, mediaElement)
    mediaElement.remove()
  }
}
