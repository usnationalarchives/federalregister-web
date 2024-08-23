import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

// stimulus-autocomplete
// import { Autocomplete } from 'stimulus-autocomplete'
// application.register('autocomplete', Autocomplete)

// custom stimulus-autocomplete
import { Autocomplete } from 'stimulus-autocomplete'
class CustomAutocomplete extends Autocomplete {
  buildURL(query) {
    const url = new URL(this.urlValue, window.location.href)
    const params = new URLSearchParams(url.search.slice(1))
    params.append("query", query)

    this.element.querySelectorAll('.modal input[data-param]').forEach((el, i) => {
      if (el.value != "") params.append(el.getAttribute('data-param'), el.value)
    })

    url.search = params.toString()
    return url.toString()
  }

  select(target) {
    super.select(target)
    this.inputTarget.dispatchEvent(new Event("focus"))
  }

  commit(selected) { // monkey-patch out inputTarget interactions
    if (selected.getAttribute("aria-disabled") === "true") return

    if (selected instanceof HTMLAnchorElement) {
      selected.click()
      this.close()
      return
    }

    const textValue = selected.getAttribute("data-autocomplete-label") || selected.textContent.trim()
    const value = selected.getAttribute("data-autocomplete-value") || textValue
    //this.inputTarget.value = textValue

    if (this.hasHiddenTarget) {
      this.hiddenTarget.value = value
      this.hiddenTarget.dispatchEvent(new Event("input"))
      this.hiddenTarget.dispatchEvent(new Event("change"))
    } else {
      this.inputTarget.value = value
    }

    // this.inputTarget.focus()
    // this.hideAndRemoveOptions()

    this.element.dispatchEvent(
      new CustomEvent("autocomplete.change", {
        bubbles: true,
        detail: { value: value, textValue: textValue, selected: selected }
      })
    )
  }

  onInputChange = () => { // monkey-patch out user input trim
    this.element.removeAttribute("value")
    if (this.hasHiddenTarget) this.hiddenTarget.value = ""

    const query = this.inputTarget.value // .trim()
    if (query && query.length >= this.minLengthValue) {
      this.fetchResults(query)
    } else {
      this.hideAndRemoveOptions()
    }
  }
}
application.register('autocomplete', CustomAutocomplete)

export { application }
