import { Controller } from "@hotwired/stimulus"

// Manages word selection across pagination via sessionStorage.
// Emits "bulk-select:changed" on document when selection changes.
// Listens for "bulk-select:request-ids" to expose current selection to other controllers.
//
// Targets:
//   pageSelectAll       — checkbox "select all on this page"
//   allMatchesButton    — button "select all N matches" (sets select_all=1 hidden field)
//   checkbox            — per-row word checkboxes (data-word-id required)
//   count               — top counter element
//   summary             — text "12 ausgewählt (über 3 Seiten)" in search bar
//   actionBar           — floating bottom bar
//   actionBarCount      — counter in the action bar
//   submitButton        — Apply buttons (top + bottom)
//   selectAllField      — hidden input <input name="select_all" value="0|1">
//
// Values:
//   storageKey      — sessionStorage key
//   signature       — JSON-serialized current search signature; mismatch → reset
//   countTemplate   — string with %{count} placeholder
export default class extends Controller {
  static targets = [
    "pageSelectAll", "allMatchesButton", "checkbox", "count", "summary",
    "actionBar", "actionBarCount", "submitButton", "selectAllField"
  ]
  static values = {
    storageKey: { type: String, default: "bulk_edit_selection" },
    signature:  { type: String, default: "" },
    countTemplate: { type: String, default: "" }
  }

  initialize() {
    this.requestHandler = (event) => {
      event.detail.ids = this.allMatches ? [] : this.idsArray
    }
    this.submitEndHandler = (event) => {
      // After a successful apply, clear the persisted selection so the user starts fresh.
      // Failures (validation errors) leave the selection intact.
      if (event.detail?.success && event.target === this.element) this.reset()
    }
  }

  connect() {
    document.addEventListener("bulk-select:request-ids", this.requestHandler)
    this.element.addEventListener("turbo:submit-end", this.submitEndHandler)
    this.restoreFromStorage()
    this.refreshUI()
  }

  disconnect() {
    document.removeEventListener("bulk-select:request-ids", this.requestHandler)
    this.element.removeEventListener("turbo:submit-end", this.submitEndHandler)
  }

  get idsSet() {
    if (!this._ids) this._ids = new Set()
    return this._ids
  }

  get idsArray() {
    return Array.from(this.idsSet)
  }

  get allMatches() {
    return this.hasSelectAllFieldTarget && this.selectAllFieldTarget.value === "1"
  }

  // ----- sessionStorage -----

  restoreFromStorage() {
    try {
      const raw = sessionStorage.getItem(this.storageKeyValue)
      if (!raw) return
      const data = JSON.parse(raw)
      if (data.signature !== this.signatureValue) {
        sessionStorage.removeItem(this.storageKeyValue)
        return
      }
      this._ids = new Set(data.ids)
      if (data.allMatches && this.hasSelectAllFieldTarget) {
        this.selectAllFieldTarget.value = "1"
      }
    } catch (e) {
      sessionStorage.removeItem(this.storageKeyValue)
    }
  }

  persist() {
    const data = {
      signature: this.signatureValue,
      ids: this.idsArray,
      allMatches: this.allMatches
    }
    sessionStorage.setItem(this.storageKeyValue, JSON.stringify(data))
  }

  // ----- Checkbox handlers -----

  toggleCheckbox(event) {
    const cb = event.currentTarget
    const wid = parseInt(cb.dataset.wordId, 10)
    if (cb.checked) this.idsSet.add(wid)
    else this.idsSet.delete(wid)

    // Individual click cancels "Alle Treffer"-mode → fall back to explicit selection.
    if (this.allMatches) this.disableAllMatches()

    this.persist()
    this.refreshUI()
    this.emitChanged()
  }

  togglePage() {
    const checked = this.pageSelectAllTarget.checked
    this.checkboxTargets.forEach(cb => {
      cb.checked = checked
      const wid = parseInt(cb.dataset.wordId, 10)
      if (checked) this.idsSet.add(wid)
      else this.idsSet.delete(wid)
    })
    if (this.allMatches && !checked) this.disableAllMatches()
    this.persist()
    this.refreshUI()
    this.emitChanged()
  }

  toggleAllMatches() {
    if (!this.hasSelectAllFieldTarget) return
    if (this.allMatches) {
      this.disableAllMatches()
    } else {
      this.selectAllFieldTarget.value = "1"
      this.checkboxTargets.forEach(cb => { cb.checked = true; cb.disabled = true })
    }
    this.persist()
    this.refreshUI()
    this.emitChanged()
  }

  disableAllMatches() {
    if (this.hasSelectAllFieldTarget) this.selectAllFieldTarget.value = ""
    this.checkboxTargets.forEach(cb => { cb.disabled = false })
  }

  reset() {
    this.idsSet.clear()
    if (this.hasSelectAllFieldTarget) this.selectAllFieldTarget.value = ""
    this.checkboxTargets.forEach(cb => { cb.checked = false; cb.disabled = false })
    if (this.hasPageSelectAllTarget) this.pageSelectAllTarget.checked = false
    sessionStorage.removeItem(this.storageKeyValue)
    this.refreshUI()
    this.emitChanged()
  }

  // ----- UI refresh -----

  refreshUI() {
    // Mark visible checkboxes from sessionStorage.
    let visibleSelected = 0
    let visibleTotal = 0
    this.checkboxTargets.forEach(cb => {
      visibleTotal++
      const wid = parseInt(cb.dataset.wordId, 10)
      const isSel = this.idsSet.has(wid) || this.allMatches
      cb.checked = isSel
      cb.disabled = this.allMatches
      if (isSel) visibleSelected++
    })

    if (this.hasPageSelectAllTarget) {
      this.pageSelectAllTarget.checked = visibleSelected > 0 && visibleSelected === visibleTotal
      this.pageSelectAllTarget.indeterminate = visibleSelected > 0 && visibleSelected < visibleTotal
      this.pageSelectAllTarget.disabled = this.allMatches
    }

    let countText
    if (this.allMatches) {
      const totalMatches = parseInt(this.element.dataset.totalMatches || "0", 10)
      countText = this.countTemplateValue.replace("%{count}", String(totalMatches))
    } else {
      const n = this.idsArray.length
      countText = (n === 0) ? "" : this.countTemplateValue.replace("%{count}", String(n))
    }

    if (this.hasCountTarget) this.countTarget.textContent = countText
    if (this.hasSummaryTarget) this.summaryTarget.textContent = countText
    if (this.hasActionBarCountTarget) this.actionBarCountTarget.textContent = countText

    const hasSelection = this.allMatches || this.idsArray.length > 0
    if (this.hasActionBarTarget) {
      this.actionBarTarget.classList.toggle("hidden", !hasSelection)
    }

    // Ensure hidden inputs reflect all selected IDs (across pages, from sessionStorage).
    this.syncHiddenIds()
  }

  // Writes one <input type="hidden" name="selected_ids[]" value="..."> per selected ID.
  // Replaces the previous batch each time so the form always reflects the latest state.
  syncHiddenIds() {
    let container = this.element.querySelector("[data-bulk-select-hidden-ids]")
    if (!container) {
      container = document.createElement("div")
      container.dataset.bulkSelectHiddenIds = "true"
      container.style.display = "none"
      this.element.appendChild(container)
    }
    container.innerHTML = ""
    this.idsArray.forEach(id => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "selected_ids[]"
      input.value = String(id)
      container.appendChild(input)
    })
  }

  emitChanged() {
    document.dispatchEvent(new CustomEvent("bulk-select:changed", { detail: { ids: this.idsArray, allMatches: this.allMatches } }))
  }
}
