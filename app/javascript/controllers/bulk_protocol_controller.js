import { Controller } from "@hotwired/stimulus"

// Toggles a protocol row's detail panel. The detail row is the *next sibling* in the table
// (we can't put a div around two <tr>s, so Stimulus targets don't help here).
// The detail row contains a <turbo-frame> whose src is set lazily on first expand.
export default class extends Controller {
  toggle(event) {
    const button = event.currentTarget
    const triggerRow = this.element
    const detailRow = triggerRow.nextElementSibling
    if (!detailRow) return

    const frame = detailRow.querySelector("turbo-frame")
    const expanded = detailRow.style.display !== "none"

    if (expanded) {
      detailRow.style.display = "none"
      this.rotateChevron(button, false)
    } else {
      if (frame && !frame.src) {
        frame.src = button.dataset.url
      }
      detailRow.style.display = ""
      this.rotateChevron(button, true)
    }
  }

  rotateChevron(button, expanded) {
    const chevron = button.querySelector("svg")
    if (chevron) chevron.style.transform = expanded ? "rotate(90deg)" : ""
  }
}
