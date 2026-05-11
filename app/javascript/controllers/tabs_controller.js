import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static classes = ["active"]

  switch(event) {
    event.preventDefault()
    const panelId = event.currentTarget.dataset.tabsPanel

    this.tabTargets.forEach(tab => {
      if (tab.dataset.tabsPanel === panelId) {
        tab.className = "px-4 py-2 cursor-pointer font-bold shadow border bg-white"
      } else {
        tab.className = "px-4 py-2 cursor-pointer hover:bg-white"
      }
    })

    this.panelTargets.forEach(panel => {
      panel.style.display = panel.id === panelId ? "" : "none"
    })
  }
}
