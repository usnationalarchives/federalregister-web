import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  suggestions(event) {
    event.preventDefault();
    Stimulus.getControllerForElementAndIdentifier(document.querySelector('#suggestions'), "suggestions").modal();
  }
}
