import { Controller } from "@hotwired/stimulus"
import { get } from '@rails/request.js'
import TomSelect from "tom-select"

export default class extends Controller {
  static values = {url: String}

  connect() {
    let options = {
      onItemAdd:function(){
        this.setTextboxValue('');
        this.refreshOptions();
      },
    }

    if(this.urlValue.replace(/\s/g, '').length > 0) {
      options = {
        ...options,
        load: (query, callback) => this.search(query, callback)
      }
    }

    if(this.element.hasAttribute("multiple")) {
      options = {
        ...options,
        plugins: ['remove_button']
      }
    }

    new TomSelect(this.element, {
      valueField: 'value',
      ...options
    })
    this.element.classList.add("hidden")
  }

  async search(q, callback) {
    const response = await get(this.urlValue, {
      query: { q },
      responseKind: 'json'
    })

    if (response.ok) {
      const list = await response.json
      callback(list)
    } else {
      console.error(response)
      callback()
    }
  }
}
