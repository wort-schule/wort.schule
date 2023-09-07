import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  search() {
    var form = this.element
    var formData = new FormData(form)
    var params = new URLSearchParams(formData)
    var queryString = params.toString()
    var href = `/seite/search?${queryString}`

    fetch(href, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
      .then(_ => history.pushState(history.state, "", href))
  }
}
