import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  suggestions(event) {
    event.preventDefault();

    if (this.data.get('agency-scoped-search')) {
      var querySelector = '#suggestions.agency-scoped-search'
    } else {
      var querySelector = '#suggestions'
    }

    Stimulus.getControllerForElementAndIdentifier(document.querySelector(querySelector), "suggestions").modal();
  }
}
