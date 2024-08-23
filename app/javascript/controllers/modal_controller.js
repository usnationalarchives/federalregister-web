import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
  }  

  connect() {
  }

  disconnect() {
  }

  close() {
    this.element.classList.add('hidden')
  }
  
  escClose(event) {
    if (event.key === 'Escape') this.close()
  }
}
