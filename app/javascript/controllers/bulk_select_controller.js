import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectAll", "checkbox", "count"]

  toggleAll() {
    const checked = this.selectAllTarget.checked
    this.checkboxTargets.forEach(cb => cb.checked = checked)
    this.updateCount()
  }

  updateCount() {
    const total = this.checkboxTargets.length
    const checked = this.checkboxTargets.filter(cb => cb.checked).length
    const allChecked = checked === total
    const noneChecked = checked === 0

    this.selectAllTarget.checked = allChecked
    this.selectAllTarget.indeterminate = !allChecked && !noneChecked

    if (this.hasCountTarget) {
      if (checked > 0) {
        this.countTarget.textContent = `${checked} ausgewählt`
      } else {
        this.countTarget.textContent = ""
      }
    }
  }
}
