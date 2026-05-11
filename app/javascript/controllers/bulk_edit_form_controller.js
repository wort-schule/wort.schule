import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fieldSelect", "operationWrapper", "valueInput"]

  static values = {
    habtmFields: { type: Array, default: ["topics", "strategies", "phenomenons"] },
    belongsToFields: { type: Array, default: ["hierarchy_id", "prefix_id", "postfix_id"] },
    booleanFields: { type: Array, default: ["prototype", "foreign", "compound"] }
  }

  connect() {
    this.toggleInputs()
  }

  toggleInputs() {
    const field = this.fieldSelectTarget.value

    // Show/hide operation select (only for HABTM)
    if (this.hasOperationWrapperTarget) {
      this.operationWrapperTarget.style.display = this.habtmFieldsValue.includes(field) ? "" : "none"
    }

    // Show/hide correct value input
    this.valueInputTargets.forEach(el => {
      el.style.display = el.dataset.field === field ? "" : "none"
    })
  }
}
