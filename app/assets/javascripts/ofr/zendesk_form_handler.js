OFR.ZendeskFormHandler = class ZendeskModalHandler {
  emailRegex = /\S+@\S+\.\S+/
  modal = document.getElementById("interstitial_modal")
  form = this.modal.querySelector("form.zendesk_ticket")

  constructor(modalHandler) {
    this.modalHandler  = modalHandler
    this.addEvents()
  }

  addEvents() {
    this.form.querySelector("button").addEventListener("click", (event) => {
      event.preventDefault()
      this.submitForm()
    })
  }

  submitForm() {
    if (this._isValidForm()) {
      this._disableSubmitButton()

      fetch("/zendesk_tickets", {
        method: 'post',
        body: this._formData()
      })
      .then((response) => {
        if (response.ok) {
          this._enableSubmitButton()
          this.modalHandler.success()
        } else if (response.status === 500) {
          throw response
        } else {
          return response.json()
        }
      })
      .then((data) => {
        alert(`
          We're sorry, an error occurred when trying to submit your request.
          ${data.errors}
        `)
      })
      .catch(() => {
        alert(
          "We're sorry, an error occurred when trying to submit your request. We've been notified about this issue and we'll take a look at it shortly."
        )
      })
    } else {
      this._markInvalidFields()
    }
  }

  _browserMetadata() {
    // using Object Destructuring and Property Shorthand
    let metadata = (({blink, name, osname, osversion, version}) => (
      {blink, name, osname, osversion, version}
    ))(bowser)

    metadata.project = 'FR'
    metadata.currentPage = window.location.href
    metadata.referrer = document.referrer

    return JSON.stringify(metadata)
  }

  _disableSubmitButton() {
    this.form
      .querySelector("button[type=submit]")
      .disabled = true
  }

  _enableSubmitButton() {
    this.form
      .querySelector("button[type=submit]")
      .disabled = false
  }

  _formData() {
    let formData = new FormData(this.form)

    formData.append('browser_metadata', this._browserMetadata())
    return formData
  }

  _isValidField(field) {
    if (field.getAttribute("type") === "checkbox") {
      // only one checkbox and it is required
      return field.checked
    } else {
      return field.value !== ""
    }
  }

  _isValidEmail() {
    let email = document.getElementById("zendesk_ticket_email").value

    return this.emailRegex.test(email)
  }

  _isValidForm() {
    let allFieldsValid = Array.from(this._requiredFields())
      .every((field) => {
        return this._isValidField(field)
      })

    return allFieldsValid && this._isValidEmail()
  }

  _markInvalidFields() {
    this._requiredFields().forEach((field) => {
      let label = field.getAttribute("type") === "checkbox" ?
        field.parentElement :
        field.parentElement.querySelector('label')

      // reset any errors
      label.classList.remove('required-error')

      // mark invalid fields
      if (!this._isValidField(field)) {
        label.classList.add('required-error')
      }

      // mark invalid email
      if (!this._isValidEmail()) {
        this.form
          .querySelector("label[for=zendesk_ticket_email]")
          .classList.add('required-error')
      }
    })
  }

  _requiredFields() {
    return this.form.querySelectorAll(
      `
        input:not([type=hidden]):not([type=file]),
        textarea:not([type=hidden])
      `
    )
  }
}
