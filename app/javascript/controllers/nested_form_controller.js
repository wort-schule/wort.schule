import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['target', 'template']
  static values = {
    wrapperSelector: {
      type: String,
      default: '.nested-form-wrapper'
    }
  }

  add(event) {
    event.preventDefault()

    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    this.targetTarget.insertAdjacentHTML('beforebegin', content)
  }

  remove(event) {
    event.preventDefault()

    const wrapper = event.target.closest(this.wrapperSelectorValue)
    wrapper.remove()
  }
}
