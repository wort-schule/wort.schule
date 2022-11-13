import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="default-theme"
export default class extends Controller {
  static targets = ["input", "wordType"]

  insert() {
    if(this.inputTarget.value.length <= 0 || confirm(window.templateOverwriteConfirmation)) {
      this.setTemplate()
    }
  }

  setTemplate() {
    const selectedWordType = this.wordTypeTarget.selectedOptions[0].value

    this.inputTarget.value = window.defaultTemplates[selectedWordType]
  }
}
