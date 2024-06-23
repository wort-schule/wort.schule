import { Controller } from "@hotwired/stimulus"
import { Compartment } from "@codemirror/state"
import { EditorView, keymap } from "@codemirror/view"
import { html } from "@codemirror/lang-html"
import { defaultHighlightStyle, syntaxHighlighting, indentOnInput } from "@codemirror/language"
import { autocompletion } from "@codemirror/autocomplete"
import { defaultKeymap } from "@codemirror/commands"

// Connects to data-controller="code-editor"
export default class extends Controller {
  static targets = ["input", "wordType"]
  static values = { wordType: String }

  connect() {
    const language = new Compartment
    const extensions = [
      language.of(html()),
      syntaxHighlighting(defaultHighlightStyle, {fallback: true}),
      indentOnInput(),
      autocompletion(),
      keymap.of(defaultKeymap)
    ]
    const textarea = this.inputTarget

    this.view = new EditorView({doc: textarea.value, extensions})
    textarea.parentNode.insertBefore(this.view.dom, textarea)
    textarea.style.display = "none"
    if (textarea.form) textarea.form.addEventListener("submit", () => {
      textarea.value = this.view.state.doc.toString()
    })
  }

  insert() {
    if(this.inputTarget.value.length <= 0 || confirm(window.templateOverwriteConfirmation)) {
      this.setTemplate()
    }
  }

  setTemplate() {
    const selectedWordType = this.hasWordTypeTarget ? this.wordTypeTarget.selectedOptions[0].value : this.wordTypeValue
    const template = window.defaultTemplates[selectedWordType]

    const transaction = this.view.state.update({changes: {from: 0, to: this.view.state.doc.length, insert: template}})
    this.view.dispatch(transaction)
  }
}
