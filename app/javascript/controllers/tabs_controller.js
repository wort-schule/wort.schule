import { Controller } from "@hotwired/stimulus"

// Generic tabs controller.
// Targets:
//   tab    — clickable tab triggers, each with data-tabs-panel="<id>"
//   panel  — the panels to show/hide, each with id matching a tab's data-tabs-panel
// On connect, reads location.hash and activates the matching tab if present.
// Adds/removes a "tab-active" CSS class on tabs (defined in the host project's CSS).
export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    if (this.tabTargets.length === 0) return
    const hash = window.location.hash.replace(/^#/, "")
    const matchingTab = hash && this.tabTargets.find(t => t.dataset.tabsPanel === hash)
    const panelId = matchingTab?.dataset?.tabsPanel ?? this.tabTargets[0]?.dataset?.tabsPanel
    this.activate(panelId)
  }

  switch(event) {
    event.preventDefault()
    this.activate(event.currentTarget.dataset.tabsPanel)
  }

  activate(panelId) {
    if (!panelId) return
    const activeTabClasses = ["font-bold", "shadow", "border", "bg-white"]
    const inactiveTabClasses = ["hover:bg-white"]

    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tabsPanel === panelId
      activeTabClasses.forEach(c => tab.classList.toggle(c, isActive))
      inactiveTabClasses.forEach(c => tab.classList.toggle(c, !isActive))
    })

    this.panelTargets.forEach(panel => {
      panel.style.display = panel.id === panelId ? "" : "none"
    })
  }
}
