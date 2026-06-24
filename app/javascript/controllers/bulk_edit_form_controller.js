import { Controller } from "@hotwired/stimulus"

// Controls the bulk-edit assignment panel:
// - toggles visibility of operation-wrapper and value-inputs based on the chosen field
// - disables/enables value-inputs so only the active one is submitted
// - live-preview: counts how many of the selected words will actually change
// - smart-default for HABTM: picks "add" or "remove" based on current state
// - confirm threshold: sets data-turbo-confirm on submit button when affected count is high
export default class extends Controller {
  static targets = [
    "fieldSelect", "operationWrapper", "operationSelect", "valueInput",
    "previewText", "submitButton", "currentValueCell", "dynamicColumnHeader",
    "boolUnset", "operationFallback"
  ]
  static values = {
    confirmThreshold: { type: Number, default: 50 },
    confirmTemplate:  { type: String, default: "" },
    habtmFields:      { type: Array, default: [] },
    belongsToFields:  { type: Array, default: [] },
    booleanFields:    { type: Array, default: [] }
  }

  connect() {
    this.userPickedOperation = false
    this.fieldChanged()
  }

  // The bulk_select controller emits this when the user selection changes.
  // Listen on the document for the custom event so we don't need a tight coupling.
  selectionChanged = () => {
    this.updatePreview()
    this.applySmartDefault()
  }

  initialize() {
    document.addEventListener("bulk-select:changed", this.selectionChanged)
  }

  disconnect() {
    document.removeEventListener("bulk-select:changed", this.selectionChanged)
  }

  fieldChanged() {
    this.userPickedOperation = false
    this.toggleInputs()
    this.applySmartDefault()
    this.updateDynamicColumn()
    this.updatePreview()
  }

  operationChanged() {
    this.userPickedOperation = true
    this.updatePreview()
  }

  valueChanged() {
    this.applySmartDefault()
    this.updatePreview()
  }

  toggleInputs() {
    const field = this.fieldSelectTarget.value
    const type = this.activeFieldType

    if (this.hasOperationWrapperTarget) {
      this.operationWrapperTarget.style.display = (type === "habtm") ? "" : "none"
    }

    // Show only the matching value input, disable all others so the form doesn't submit them.
    this.valueInputTargets.forEach(el => {
      const matches = el.dataset.field === field
      el.style.display = matches ? "" : "none"
      el.querySelectorAll("input, select").forEach(input => {
        input.disabled = !matches
        // TomSelect wraps the native <select> and doesn't observe its `disabled`
        // property, so toggling it above leaves the widget greyed-out. Drive the
        // widget's own enable/disable API to keep the active picker interactive.
        if (input.tomselect) {
          if (matches) {
            input.tomselect.enable()
          } else {
            input.tomselect.disable()
          }
        }
      })
    })

    // For non-HABTM, the operation is implicitly "set" — write to fallback hidden field.
    if (this.hasOperationFallbackTarget) {
      this.operationFallbackTarget.disabled = (type === "habtm")
      if (this.hasOperationSelectTarget) this.operationSelectTarget.disabled = (type !== "habtm")
    }
  }

  get activeOption() {
    const select = this.fieldSelectTarget
    return select.options[select.selectedIndex]
  }

  get activeValueInput() {
    return this.valueInputTargets.find(el => el.dataset.field === this.fieldSelectTarget.value)
  }

  get activeFieldType() {
    const field = this.fieldSelectTarget.value
    if (this.habtmFieldsValue.includes(field)) return "habtm"
    if (this.belongsToFieldsValue.includes(field)) return "belongs_to"
    if (this.booleanFieldsValue.includes(field)) return "boolean"
    return ""
  }

  // Reads the current desired value from the active value input.
  // Returns null if no value chosen.
  readValue() {
    const input = this.activeValueInput
    if (!input) return null
    const type = input.dataset.fieldType
    if (type === "habtm") {
      const select = input.querySelector("select")
      if (!select) return null
      return Array.from(select.selectedOptions).map(o => parseInt(o.value, 10)).filter(n => !isNaN(n))
    }
    if (type === "belongs_to") {
      const select = input.querySelector("select")
      const v = select?.value
      return (v == null || v === "") ? null : parseInt(v, 10)
    }
    if (type === "boolean") {
      const checked = input.querySelector("input[type=radio]:checked")
      if (!checked || checked.value === "") return null
      return checked.value === "true"
    }
    return null
  }

  selectedWordIds() {
    const event = new CustomEvent("bulk-select:request-ids", { detail: {}, bubbles: true })
    document.dispatchEvent(event)
    return Array.isArray(event.detail.ids) ? event.detail.ids : []
  }

  updatePreview() {
    const field = this.fieldSelectTarget.value
    if (!field || !this.hasPreviewTextTarget) return

    const value = this.readValue()
    const ids = this.selectedWordIds()
    const allMatches = this.element.querySelector("[data-bulk-select-target='selectAllField']")?.value === "1"
    const operation = this.activeFieldType === "habtm"
      ? (this.hasOperationSelectTarget ? this.operationSelectTarget.value : "add")
      : "set"

    const valueChosen = !(value === null || (Array.isArray(value) && value.length === 0))
    const hasSelection = allMatches || ids.length > 0

    if (!hasSelection || !valueChosen) {
      this.previewTextTarget.textContent = ""
      this.setSubmitEnabled(false)
      this.removeConfirm()
      return
    }

    if (allMatches) {
      const total = parseInt(this.element.dataset.totalMatches || "0", 10)
      this.previewTextTarget.textContent = total > 0
        ? this.t("preview_all", { total: total })
        : this.t("preview_all_unknown", {})
      this.setSubmitEnabled(total > 0)
      this.maybeAddConfirm(total)
      return
    }

    // Iterate selected rows we have in the DOM. Words on other pages are unknown — assume changes.
    let willChange = 0
    let domSeen = 0
    const idSet = new Set(ids.map(Number))
    this.element.querySelectorAll("tr[data-word-id]").forEach(row => {
      const wid = parseInt(row.dataset.wordId, 10)
      if (!idSet.has(wid)) return
      domSeen++
      if (this.rowWouldChange(row, field, value, operation)) willChange++
    })
    const unknownOnOtherPages = ids.length - domSeen
    const totalEffective = willChange + Math.max(0, unknownOnOtherPages)

    this.previewTextTarget.textContent = this.t("preview", {
      effective: totalEffective,
      total: ids.length,
      noop: ids.length - totalEffective
    })

    this.setSubmitEnabled(totalEffective > 0)
    this.maybeAddConfirm(totalEffective)
  }

  rowWouldChange(row, field, value, operation) {
    const raw = row.dataset[`current${field.split("_").map((s, i) => i === 0 ? s : s[0].toUpperCase() + s.slice(1)).join("")}`]
    // dataset auto-camelCases — manually convert "current_hierarchy_id" → "currentHierarchyId"
    const key = "current" + field.split("_").map(p => p[0].toUpperCase() + p.slice(1)).join("")
    const cur = JSON.parse(row.dataset[key] || "null")
    const type = this.activeFieldType
    if (type === "habtm") {
      const current = Array.isArray(cur) ? cur.map(Number) : []
      const desired = Array.isArray(value) ? value.map(Number) : []
      if (operation === "add") return desired.some(v => !current.includes(v))
      if (operation === "remove") return desired.some(v => current.includes(v))
      return false
    }
    if (type === "belongs_to") {
      return Number(cur) !== Number(value)
    }
    if (type === "boolean") {
      return Boolean(cur) !== Boolean(value)
    }
    return false
  }

  applySmartDefault() {
    if (this.userPickedOperation) return
    if (this.activeFieldType !== "habtm" || !this.hasOperationSelectTarget) return

    const value = this.readValue()
    if (!Array.isArray(value) || value.length === 0) return

    const ids = this.selectedWordIds()
    if (ids.length === 0) return

    let withVal = 0
    let total = 0
    const idSet = new Set(ids.map(Number))
    const field = this.fieldSelectTarget.value
    const key = "current" + field.split("_").map(p => p[0].toUpperCase() + p.slice(1)).join("")
    this.element.querySelectorAll("tr[data-word-id]").forEach(row => {
      const wid = parseInt(row.dataset.wordId, 10)
      if (!idSet.has(wid)) return
      total++
      const cur = JSON.parse(row.dataset[key] || "[]")
      if (value.some(v => cur.includes(v))) withVal++
    })
    if (total === 0) return

    const majorityHave = (withVal / total) >= 0.5
    this.operationSelectTarget.value = majorityHave ? "remove" : "add"
  }

  updateDynamicColumn() {
    const field = this.fieldSelectTarget.value
    if (!field) return
    const headerLabel = this.activeOption?.text || ""
    if (this.hasDynamicColumnHeaderTarget) {
      this.dynamicColumnHeaderTarget.textContent = headerLabel || "—"
    }
    const key = "display" + field.split("_").map(p => p[0].toUpperCase() + p.slice(1)).join("")
    this.element.querySelectorAll("[data-bulk-edit-form-target='currentValueCell']").forEach(cell => {
      const row = cell.closest("tr")
      cell.textContent = row?.dataset[key] || ""
    })
  }

  setSubmitEnabled(enabled) {
    this.submitButtonTargets.forEach(btn => {
      btn.disabled = !enabled
    })
  }

  maybeAddConfirm(count) {
    if (count >= this.confirmThresholdValue && this.confirmTemplateValue) {
      const msg = this.confirmTemplateValue.replace("%{count}", count)
      this.submitButtonTargets.forEach(btn => btn.dataset.turboConfirm = msg)
    } else {
      this.removeConfirm()
    }
  }

  removeConfirm() {
    this.submitButtonTargets.forEach(btn => delete btn.dataset.turboConfirm)
  }

  // Minimal i18n helper: looks up translations via data attributes on the form root.
  // Format strings come from the server via data-bulk-edit-form-* and have %{key} placeholders.
  t(key, vars) {
    // Convert snake_case key → camelCase, then prepend "bulkEditFormI18n":
    //   "preview_all" → "previewAll" → "bulkEditFormI18nPreviewAll" (matches Stimulus' attribute mapping)
    const camel = key.replace(/_([a-z])/g, (_, c) => c.toUpperCase())
    const datasetKey = "bulkEditFormI18n" + camel[0].toUpperCase() + camel.slice(1)
    const tmpl = this.element.dataset[datasetKey]
    if (!tmpl) {
      if (key === "preview") return `${vars.effective}/${vars.total} (${vars.noop} no-op)`
      if (key === "preview_all") return `All ${vars.total} matches`
      if (key === "preview_all_unknown") return "All matches"
      return ""
    }
    return tmpl.replace(/%\{(\w+)\}/g, (_, k) => vars[k] ?? "")
  }
}
