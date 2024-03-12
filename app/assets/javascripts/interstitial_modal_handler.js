FR2.InterstitialModalHandler = class InterstitialModalHandler {
  constructor(siteFeedbackHandler) {
    this.siteFeedbackHandler = siteFeedbackHandler
    this.displayModal()
    this.addEvents()
  }

  displayModal() {
    let modalContent = this._interstitialMarkup()

    FR2.Modal.displayModal('', modalContent, {
      includeTitle: false,
      modalClass: 'fr_modal wide',
      modalId: '#interstitial_modal',
      additionalOnHide: this.siteFeedbackHandler.modalClose,
      additionalOnShow: this.siteFeedbackHandler.modalOpen
    })
  }

  addEvents() {
    let modal = document.getElementById("interstitial_modal")

    let documentFeedbackButton = modal.querySelector(
      ".document_feedback .button:not(.disabled)"
    )

    // some pages (like EOs) won't have an addresses or other contact sections
    // and so the button won't be enabled
    if (documentFeedbackButton) {
      documentFeedbackButton.addEventListener("click", (event) => {
        event.preventDefault()
        $(modal).jqmHide()
        this._directUserComments()
      })
    }

    modal
      .querySelector(".site_feedback .button")
      .addEventListener("click", (event) => {
        event.preventDefault()
        new OFR.ZendeskModalHandler(this.siteFeedbackHandler)
      })
  }

  _determineFeedbackText() {
    let documentButtonEnabled = ""
    let documentFeedbackText = ""

    if ( this._openForComment() ) {
      documentFeedbackText = `If you would like to submit a formal comment
        to the issuing agency on the document you are currently viewing,
        please use the "Document Feedback" button below.`
    } else if( this._hasCommentInstructions() ) {
      documentFeedbackText = `If you would like to comment on the current
        document, please use the "Document Comment" button below for
        instructions on contacting the issuing agency`
    } else {
      documentFeedbackText = `The current document is not open for comment,
        please use other means to contact
        ${document.querySelector(".metadata .agencies").innerHTML} directly.`
      documentButtonEnabled = "disabled";
    }

    return [documentButtonEnabled, documentFeedbackText]
  }

  _directUserComments() {
    if (this._openForComment()) {
      document.getElementById("start_comment").trigger('click')
    } else if (document.getElementById("addresses")) {
      window.location.href = '#addresses'
    } else {
      window.location.href = '#further-info'
    }
  }

  _hasCommentInstructions() {
    let addresses = document.getElementById("addresses")
    let furtherInfo = document.getElementById("further-info")

    return addresses || furtherInfo
  }

  _interstitialMarkup() {
    let [documentButtonEnabled, documentFeedbackText] = this._determineFeedbackText()

    return `
      <div class='interstitial_modal'>
        <h3 class="title_bar">Site Feedback</h3>

        <p class="info">
          The Office of the Federal Register publishes rules, proposed rules,
          notices, and presidential documents on behalf of Federal agencies and
          the President of the United States. Although our site has the ability
          to link a user directly to the document docket on Regulations.gov,
          we do not accept or manage comments on any document we publish.
          You must submit your comments through Regulations.gov or directly to
          the agency that wrote the document.
          We will not send any comments to the agency.
        </p>

        <div class='site_feedback'>
          <p>
            If you have comments or suggestions on how to improve the
            FederalRegister.gov website or have questions about using
            FederalRegister.gov, please choose the 'Website Feedback' button
            below.
          </p>

          <div class='button' type="button">
            <span class='icon-fr2 icon-fr2-pc'></span>
            <div class='button_title'>Website Feedback</div>
          </div>
        </div>

        <div class='document_feedback'>
          <p>
            ${documentFeedbackText}
          </p>

          <div class='button ${documentButtonEnabled}' type="button">
            <span class='icon-fr2 icon-fr2-book-alt-2'></span>
            <div class='button_title'>Document Feedback</div>
          </div>
        </div>

        <div class='agency_question'>
          <p>
            If you have questions for the agency that issued the current document please contact the agency directly.
          </p>
        </div>
      </div>
    `
  }

  _openForComment() {
    let formalCommentLink = document.querySelector(".button.formal_comment")

    return formalCommentLink &&
      formalCommentLink.getAttribute("href") !== "#addresses"
  }
}
