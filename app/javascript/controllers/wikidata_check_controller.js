import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["result"]
  static values = {
    word: String,
    current: String,
    url: String
  }

  connect() {
    this.check()
  }

  async check() {
    try {
      const response = await fetch(this.urlValue)
      const data = await response.json()

      if (data.error) {
        this.resultTarget.textContent = "—"
        this.resultTarget.className = "text-xs text-gray-400"
        return
      }

      const wikiSyllables = data.syllables
      if (!wikiSyllables) {
        this.resultTarget.textContent = "—"
        this.resultTarget.className = "text-xs text-gray-400"
        return
      }

      const current = this.currentValue
      const match = current === wikiSyllables

      this.resultTarget.textContent = wikiSyllables
      if (match) {
        this.resultTarget.className = "text-xs text-green-600 font-medium"
      } else {
        this.resultTarget.className = "text-xs text-red-600 font-bold"
        this.resultTarget.title = `Erwartet: ${wikiSyllables}, Aktuell: ${current}`
      }
    } catch (e) {
      this.resultTarget.textContent = "Fehler"
      this.resultTarget.className = "text-xs text-gray-400"
    }
  }
}
