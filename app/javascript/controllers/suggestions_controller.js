import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['form', 'fulltext', 'help', 'input', 'modal', 'nonModalInput', 'nonModalForm', 'nonModalSearchIcon', 'results', 'searchIcon', 'toc']
  
  initialize() {
    this.boundInputBlur = null
    this.boundInputFocus = null
    this.boundSuggestionPicked = null
    this.boundStabilize = null
    this.attention = false
    this.everFocused = false
    this.everAbandoned = false
  }

  call_ga(event_action) {
    if (typeof ga == 'function') {
      gtag('event', 'Search', {'event_action': event_action});
    }
  }

  connect() {
    this.boundInputBlur = this.inputBlur.bind(this);
    this.inputTarget.addEventListener("blur", this.boundInputBlur);

    this.boundInputFocus = this.inputFocus.bind(this);
    this.inputTarget.addEventListener("focus", this.boundInputFocus);

    this.boundSelectDefault = this.selectDefault.bind(this);
    this.element.addEventListener("loadend", this.boundSelectDefault);

    this.boundStabilize = this.stabalize.bind(this);
    this.element.addEventListener("load", this.boundStabilize);

    this.boundSuggestionPicked = this.suggestionPicked.bind(this);
    this.element.addEventListener("autocomplete.change", this.boundSuggestionPicked);

    const reference = document.querySelector("#suggestion")
    if (reference.value != '') {
      // entry prior to init
      this.inputTarget.value = reference.value
      reference.value = ""
      this.modal(null)
    }
  }

  disconnect() {
    if (this.boundInputBlur) this.inputTarget.removeEventListener("blur", this.boundInputBlur)
    if (this.boundInputFocus) this.inputTarget.removeEventListener("focus", this.boundInputFocus)
    if (this.boundSelectDefault) this.element.removeEventListener("loadEnd", this.boundSelectDefault)
    if (this.boundStabilize) this.element.removeEventListener("load", this.boundStabilize)
    if (this.boundSuggestionPicked) this.element.removeEventListener("autocomplete.change", this.boundSuggestionPicked)
  }

  inputBlur(event) {
    event.stopPropagation()
    event.preventDefault()
    this.stabalize(event)
    document.querySelector('body').classList.remove('modal-open')
    if (!this.everAbandoned && document.hasFocus()) {
      if (!Stimulus.getControllerForElementAndIdentifier(document.querySelector('#suggestions'), "autocomplete").mouseDown) {
        this.everAbandoned = true;
        this.call_ga('suggestions abandon');
      }
    }
  }

  inputFocus(event) {
    this.stabalize(event)
    if (!this.everFocused) {
      this.everFocused = true;
      this.call_ga('suggestions interaction');
    }
  }

  modal(event) {
    document.querySelector('body').classList.add('modal-open')
    this.modalTarget.classList.remove('hidden')
    if (!(document.activeElement === this.inputTarget)) this.inputTarget.focus();
    if (this.hasResultsTarget) this.resultsTarget.hidden = false
  }

  fillExample(event) {
    event.preventDefault()
    if (event.target && this.inputTarget) {
      if (!(document.activeElement === this.inputTarget)) this.inputTarget.focus();
      this.inputTarget.value = event.target.textContent;
      Stimulus.getControllerForElementAndIdentifier(document.querySelector('#suggestions'), "autocomplete").onInputChange()
    }
  }

  go(event) {
    if (this.nonModalInputTarget.value && this.nonModalInputTarget.value) {
      this.nonModalFormTarget.submit()
    }
  }

  goDefault(event) {
    this.formTarget.submit()
  }

  search(event) {
    event.preventDefault()
    this.formTarget.submit()
  }

  suggestionPicked(event) {
    event.preventDefault()
    if (!this.everSelected) {
      this.everSelected = true;
      this.call_ga(event.detail.selected.getAttribute('data-kind') + ' selection');
    }

    var target = event.detail.value
    var index = target.indexOf("#")
    var path = (index < 1) ? false : target.substring(0, index)
    if (window.location.href.includes(target) || (path && window.location.href.includes(path))) {
      document.querySelector('body').classList.remove('modal-open')
      this.modalTarget.classList.add('hidden')
      if (document.activeElement === this.inputTarget) this.inputTarget.blur()
      if (this.hasResultsTarget) this.resultsTarget.hidden = true
    }    

    window.location.href = event.detail.value
  }

  toc(event) {
    event.stopPropagation()
  }

  hierarchySuggestionPicked(event) {
    event.stopPropagation()
  }

  selectDefault(event) {
    this.searchIconTarget.classList.add('default')
  }

  stabalize(event) {
    const items = this.element.querySelector('.suggestions')
    const item = items ? items.querySelector(".suggestion") : null
    const suggestions = document.querySelector('#suggestions')
    if (item) {
      this.formTarget.classList.add('results-available')
      this.resultsTarget.hidden = false
      
      CJ.Tooltip.addFancyTooltip(
        '.suggestions a[data-toggle="tooltip"], .suggestions span[data-toggle="tooltip"]',
        {
          trigger: 'hover',
          className: 'tooltip',
          fade: false,
          gravity: 'sw',
          opacity: 1,
          delayIn: 250
        },
        {
          position: 'leftTop',
          verticalOffset: -16,
          horizontalOffset: 6
        }
      )

    } else {
      if (this.element.querySelector('.results > .none')) {
        this.formTarget.classList.add('results-available')
        this.resultsTarget.hidden = false
      } else {
        this.formTarget.classList.remove('results-available')
        this.resultsTarget.hidden = true
      }
    }

    this.nonModalInputTarget.value = this.inputTarget.value
    
    document.querySelectorAll('#suggestion').forEach(placeholder => {
      placeholder.value = this.inputTarget.value
    })

    if (items && items.querySelector(".suggestion.active")) {
      this.searchIconTarget.classList.remove('default')
    } else {
      this.searchIconTarget.classList.add('default')
    }
  }
}
