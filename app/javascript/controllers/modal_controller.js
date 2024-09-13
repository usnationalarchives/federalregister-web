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

  forceClose(event) {
    this.close()
  }
  
  escClose(event) {
    if (event.key === 'Escape') this.close()
  }
}
