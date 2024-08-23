import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['form', 'fulltext', 'toc']

  initialize() {
    this.boundSuggestionPicked = null;
    this.boundStabilize = null;
  }

  connect() {
    this.boundSuggestionPicked = this.suggestionPicked.bind(this);
    this.element.addEventListener("autocomplete.change", this.boundSuggestionPicked);

    this.boundStabilize = this.stabalize.bind(this);
    this.element.addEventListener("load", this.boundStabilize);
  }
  
  disconnect() {
    if (this.boundSuggestionPicked) this.element.removeEventListener("autocomplete.change", this.boundSuggestionPicked);
    if (this.boundAutoselectFirst) this.element.removeEventListener("load", this.boundAutoselectFirst);
  }
  
  fulltext() {
    console.log("fulltext fulltext fulltext fulltext fulltext");
    if (this.tocTarget) this.tocTarget.classList.remove("selected");
    if (this.fulltextTarget) this.fulltextTarget.classList.add("selected");
    if (ECFR.UserPreferenceStore) ECFR.UserPreferenceStore.saveSuggestionsSetting({"preferred_content": "fulltext"});

    this.element.querySelectorAll('.suggestions .suggestion').forEach((el, i) => {
      var path = el.getAttribute('data-autocomplete-value');
      var toc_suffix = el.getAttribute('data-toc');
      if (path && toc_suffix && path.endsWith(toc_suffix)) {
        el.setAttribute('data-autocomplete-value', path.substring(0, path.length - toc_suffix.length));
      }
    });    
  }

  toc() {
    if (this.fulltextTarget) this.fulltextTarget.classList.remove("selected");
    if (this.tocTarget) this.tocTarget.classList.add("selected");
    if (ECFR.UserPreferenceStore) ECFR.UserPreferenceStore.saveSuggestionsSetting({"preferred_content": "toc"});

    this.element.querySelectorAll('.suggestions .suggestion').forEach((el, i) => {
      var path = el.getAttribute('data-autocomplete-value');
      var toc_suffix = el.getAttribute('data-toc');
      if (path && toc_suffix && !path.endsWith(toc_suffix)) {
        el.setAttribute('data-autocomplete-value', path + toc_suffix);
      }
    });
  }

  search(event) {
    event.preventDefault();
    this.formTarget.submit();
  }

  suggestionPicked(event) {
    event.preventDefault();
    window.location.href = event.detail.value;
  }

  stabalize(event) {
    this.autoselectFirst(event);
    this.adjustLinksForPreferredContent(event);
  }

  autoselectFirst(event) {
    const item = this.element.querySelector('.suggestions').querySelector(".suggestion");
    if (item) Stimulus.getControllerForElementAndIdentifier(suggestions, "autocomplete").select(item);
  }

  adjustLinksForPreferredContent(event) {
    var preference = "fulltext";
    if (ECFR.UserPreferenceStore) {
      console.log("checking preference")
      preference = ECFR.UserPreferenceStore.getSuggestionsSetting("preferred_content") || preference;
    }
    console.log("preference: " + preference);
    if (preference == "toc") this.toc();
  }
}
