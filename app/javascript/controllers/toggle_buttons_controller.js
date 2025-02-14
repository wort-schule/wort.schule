import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Connects to data-controller="toggle-buttons"
export default class extends Controller {
  static targets = [
    "list",
    "input",
    "add"
  ]

  static values = {
    items: Array,
    fixed: Array,
    checked: Boolean
  }

  connect() {
    const self = this

    this.fixedValue.forEach(item => this.addItem(item, this.checkedValue))
    this.updateButtons()

    let options = {
      options: this.itemsValue.map(item => ({value: item, text: item})),
      onItemAdd: function(value) {
        this.clear(true)
        this.refreshOptions()

        self.addItem(value, true)
      }
    }

    new TomSelect(this.addTarget, {
      valueField: 'value',
      ...options
    })
    this.addTarget.style.display = 'none'
  }

  addItem(value, checked) {
    const template = document.getElementById('item-template')
    const instance = template.content.cloneNode(true)
    const attribute = btoa(value)

    instance.querySelector('button').textContent = value
    instance.querySelector('button').dataset.value = value
    instance.querySelector('button').dataset.checked = checked

    this.listTarget.appendChild(instance)

    if (checked) {
      this.activate(value)
    }
  }

  toggle(event) {
    if (event.target.dataset.checked === "true") {
      this.deactivate(event.target.dataset.value)
    } else {
      this.activate(event.target.dataset.value)
    }

    event.target.dataset.checked = event.target.dataset.checked === "true" ? false : true
    this.updateButtons()
  }

  activate(value) {
    const values = this.valueSet()
    values.add(value)
    this.setValues(values)
  }

  deactivate(value) {
    const values = this.valueSet()
    values.delete(value)
    this.setValues(values)
  }

  valueSet() {
    return new Set(Array.from(this.inputTarget.options).map(option => option.value))
  }

  setValues(set) {
    this.inputTarget.innerHTML = ""
    Array.from(set).forEach(value => {
      const option = document.createElement("option")
      option.value = value
      option.selected = "selected"
      this.inputTarget.appendChild(option)
    })
    this.inputTarget.value = Array.from(set).join(",")
    this.updateButtons()
  }

  updateButtons() {
    const activeClasses = ['bg-primary', 'text-white', 'shadow']
    const inactiveClasses = ['bg-gray-background', 'text-primary']

    this.listTarget.querySelectorAll("button").forEach(button => {
      if (button.dataset.checked === "true") {
        inactiveClasses.forEach(klass => button.classList.remove(klass))
        activeClasses.forEach(klass => button.classList.add(klass))
      } else {
        inactiveClasses.forEach(klass => button.classList.add(klass))
        activeClasses.forEach(klass => button.classList.remove(klass))
      }
    })
  }
}
