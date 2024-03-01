OFR.CopyToClipboard = class CopyToClipboard {
  async copyToClipboard(text) {
    try {
      await navigator.clipboard.writeText(text);
    } catch (err) {
      console.error('Failed to copy: ', err);
    }
  }

  copy(event) {
    const target = event.target.closest('.copy-to-clipboard')

    if( target !== null ){
      event.preventDefault()
      event.stopPropagation()
      this.copyToClipboard(target.dataset.copyText)

      if( target.dataset.toggle === "tooltip" ) {
        target
          .parentElement
          .querySelector('.tooltip .tooltip-inner')
          .innerText = target.dataset.titleCopied
      }
    }
  }

  addTo(selector) {
    const listenTarget = document.querySelector(selector)
    if (listenTarget !== null) {
      listenTarget.addEventListener('click', this.copy.bind(this), true)
    }
  }
}
