import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["suggestions", "altTextSuggestion", "altTextField", "button", "loading"]
  static values = { url: String }

  async suggest(event) {
    event.preventDefault()

    this.buttonTarget.style.display = "none"
    this.loadingTarget.style.display = ""

    try {
      const response = await fetch(this.urlValue)
      const data = await response.json()

      if (data.error) {
        this.suggestionsTarget.innerHTML = `<p class="text-sm text-red-600">${data.error}</p>`
        this.loadingTarget.style.display = "none"
        return
      }

      this.renderSuggestions(data)
    } catch (e) {
      this.suggestionsTarget.innerHTML = `<p class="text-sm text-red-600">Fehler: ${e.message}</p>`
    }

    this.loadingTarget.style.display = "none"
  }

  renderSuggestions(data) {
    if (data.example_sentences && data.example_sentences.length > 0) {
      const html = data.example_sentences.map(sentence => `
        <div class="flex items-center gap-2 mb-1">
          <span class="flex-grow text-sm text-gray-700 bg-blue-50 px-3 py-1.5 rounded-md">${this.escapeHtml(sentence)}</span>
          <button type="button" class="text-blue-600 hover:text-blue-800 text-sm font-medium flex-shrink-0"
                  data-action="click->llm-suggest#adoptSentence"
                  data-sentence="${this.escapeAttr(sentence)}">+ Übernehmen</button>
        </div>
      `).join("")
      this.suggestionsTarget.innerHTML = html
    }

    if (data.image_alt_text && this.hasAltTextSuggestionTarget) {
      this.altTextSuggestionTarget.innerHTML = `
        <div class="flex items-center gap-2 mt-2">
          <span class="text-xs text-gray-600 bg-yellow-50 px-2 py-1 rounded">${this.escapeHtml(data.image_alt_text)}</span>
          <button type="button" class="text-blue-600 hover:text-blue-800 text-xs font-medium"
                  data-action="click->llm-suggest#adoptAltText"
                  data-alt-text="${this.escapeAttr(data.image_alt_text)}">Übernehmen</button>
        </div>
      `
    }
  }

  adoptSentence(event) {
    event.preventDefault()
    const sentence = event.currentTarget.dataset.sentence

    // Find the nested-form controller area and add a new sentence field
    const formArea = this.element.querySelector("[data-controller='nested-form']")
    if (!formArea) return

    const target = formArea.querySelector("[data-nested-form-target='target']")
    if (!target) return

    const wrapper = document.createElement("div")
    wrapper.className = "nested-form-wrapper flex gap-2 mb-2"
    wrapper.innerHTML = `
      <input type="text" name="example_sentences[]" value="${this.escapeAttr(sentence)}"
             class="flex-grow px-3 py-2 border border-gray-300 rounded-md text-sm" />
      <button type="button" class="text-gray-400 hover:text-red-500" data-action="nested-form#remove">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-5 h-5">
          <path fill-rule="evenodd" d="M5.47 5.47a.75.75 0 0 1 1.06 0L12 10.94l5.47-5.47a.75.75 0 1 1 1.06 1.06L13.06 12l5.47 5.47a.75.75 0 1 1-1.06 1.06L12 13.06l-5.47 5.47a.75.75 0 0 1-1.06-1.06L10.94 12 5.47 6.53a.75.75 0 0 1 0-1.06Z" clip-rule="evenodd" />
        </svg>
      </button>
    `
    target.insertAdjacentElement("beforebegin", wrapper)

    // Mark as adopted visually
    event.currentTarget.textContent = "✓"
    event.currentTarget.disabled = true
    event.currentTarget.classList.remove("text-blue-600", "hover:text-blue-800")
    event.currentTarget.classList.add("text-green-600")
  }

  adoptAltText(event) {
    event.preventDefault()
    const altText = event.currentTarget.dataset.altText

    if (this.hasAltTextFieldTarget) {
      this.altTextFieldTarget.value = altText
    }

    event.currentTarget.textContent = "✓"
    event.currentTarget.disabled = true
    event.currentTarget.classList.remove("text-blue-600", "hover:text-blue-800")
    event.currentTarget.classList.add("text-green-600")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  escapeAttr(text) {
    return text.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/'/g, "&#39;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
  }
}
