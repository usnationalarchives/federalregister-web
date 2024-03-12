OFR.SiteFeedbackHandler = class SiteFeedbackHandler {
  siteFeedbackButtons = document.querySelectorAll(".site-feedback-button");

  constructor(contentPage, interstitialModalHandler) {
    this.contentPage = contentPage
    this.interstitialModalHandler = interstitialModalHandler
    this.addEvents()
  }

  addEvents() {
    this.siteFeedbackButtons.forEach((siteFeedbackButton) =>
      siteFeedbackButton.addEventListener("click", (event) => {
        event.preventDefault()
        if (siteFeedbackButton.classList.contains("disabled")) return

        this.displayModal()
      })
    )
  }

  displayModal() {
    if (this.contentPage) {
      new FR2.InterstitialModalHandler(this)
    } else {
      new OFR.ZendeskModalHandler(this)
    }
  }

  modalClose() {
    // note: `this` is now the FR modal code
    document.querySelectorAll(".site-feedback-button").forEach(
      (siteFeedbackButton) =>
        siteFeedbackButton.classList.remove("disabled")
    )
  }

  modalOpen() {
    // note: `this` is now the FR modal code
    document.querySelectorAll(".site-feedback-button").forEach(
      (siteFeedbackButton) =>
        siteFeedbackButton.classList.add("disabled")
    )
  }
}
