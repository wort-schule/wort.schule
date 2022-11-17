import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flashcard-drag"
export default class extends Controller {
  connect() {}

  dragstart(event) {
    const draggingElement = event.target

    event.dataTransfer.setData("wordId", draggingElement.dataset.wordId)
    event.dataTransfer.effectAllowed = "move"

    this.sourceListId = draggingElement.dataset.listId
  }

  dragover(event) {
    event.preventDefault()

    const dropTarget = event.target
    const listElement = dropTarget.closest('div[data-list-id]')

    if(!listElement) return false

    const dragoverListId = listElement.dataset.listId

    if(this.sourceListId === dragoverListId) return false

    if(listElement) {
      listElement.classList.add('dropzone')

      return true
    }

    return false
  }

  dragenter(event) {
    event.preventDefault()
  }

  dragleave(event) {
    event.preventDefault()

    const dropTarget = event.target
    const listElement = dropTarget.closest('div[data-list-id]')

    if(listElement) listElement.classList.remove('dropzone')
  }

  drop(event) {
    const wordId = event.dataTransfer.getData("wordId")
    const dropTarget = event.target
    const listElement = dropTarget.closest('div[data-list-id]')

    if(listElement) {
      const listId = listElement.dataset.listId
      event.dataTransfer.setData("listId", event.target.dataset.listId)

    fetch(`/lists/${listId}/move_word`, {
      method: 'PATCH',
      body: JSON.stringify({
        word_id: wordId,
      }),
      headers: {
        'Content-type': 'application/json; charset=UTF-8',
      },
    })
      .then((_response) => window.location.reload())
    }

    event.preventDefault()
  }

  dragend(_event) {}
}
