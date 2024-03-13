FR2.PrintPageElements = class PrintPageElements {
  contentCol = document.querySelector(".doc-content .content-col");

  shortUrl = this.contentCol.querySelector(".doc-content-area").dataset.shortUrl

  volume = document.getElementById("document-citation").dataset.citationVol

  addUIEvents() {
    // start hover
    this.contentCol.addEventListener("mouseenter", (event) => {
      let target = event.target

      if (!this.printPageTarget(target)) return

      let icon = "doc-filled";
      this.updateUI(target, icon);
    }, true)

    // end hover
    this.contentCol.addEventListener("mouseleave", (event) => {
      let target = event.target

      if (!this.printPageTarget(target)) return;

      let icon = "doc-generic";
      this.updateUI(target, icon);
    }, true)

    // click
    document.body.addEventListener("click", (event) => {
      let target = event.target

      let pageDetailsTarget = target.closest(".printed-page-details")

      if (pageDetailsTarget === null) {
        // close menu on click elsewhere
        let openMenu = this.contentCol
          .querySelector(".printed-page-details.menu-open")

        if (openMenu) {
          openMenu.classList.remove("menu-open");
          this.hideDetailsMenu(openMenu);
        }
      } else {
        // don't do anything if the click was in the page menu box
        // but .page-menu is a wrapper with a background blur and we want that
        // to close the menu if clicked
        if (target.closest(".page-menu-box") !== null) return;

        if (pageDetailsTarget.classList.contains("menu-open")) {
          pageDetailsTarget.classList.remove("menu-open");
          this.hideDetailsMenu(pageDetailsTarget);
        } else {
          pageDetailsTarget.classList.add("menu-open");
          this.displayDetailsMenu(pageDetailsTarget);
        }
      }
    }, true)

    // close menu on escape key press
    document.body.addEventListener('keyup', (event) => {
      if (event.key === "Escape") {
        let openMenu = this.contentCol
          .querySelector(".printed-page-details.menu-open")

        if (openMenu) {
          openMenu.classList.remove("menu-open");
          this.hideDetailsMenu(openMenu);
        }
      }
    })
  }

  displayDetailsMenu(target) {
    if (this.pageMenu(target)) {
      this.pageMenu(target).classList.remove("hidden")
      $(target).tipsy('hide')
    } else {
      let menu = document.createElement("div")

      menu.classList.add("page-menu")
      menu.innerHTML = this.paragraphDetailsMenuMarkup(
        target.dataset.page, this.shortUrl, this.volume
      )
      let boxLeftCSSValue = 60;
      let gutterOffsetWidth = 30;
      menu.style.width = `${this.contentCol.offsetWidth - boxLeftCSSValue - gutterOffsetWidth}px`

      target.append(menu)
      $(target).tipsy('hide')
    }
  }

  enable() {
    this.addUIEvents();
  }

  hideDetailsMenu(printedPageDetails) {
    this.pageMenu(printedPageDetails).classList.add("hidden")
  }

  // used when page loads to visually identify if a page has been linked to
  // as part of the url
  highlightPageTargets(targetedPageDetails, tooltipText) {
    let pageDetails = document.getElementById(
      targetedPageDetails.replace("#", "")
    )

    if (!pageDetails) return;

    pageDetails.classList.add("highlight")
    pageDetails.dataset.
      tooltip = `Click for more print page information. <br> ${tooltipText}`
    this.swapIcon(pageDetails, "doc-filled")

    let pageInline = this.correspondingTextualtem(
      this.pageNumber(pageDetails)
    )
    pageInline.classList.add("highlight")
    this.swapIcon(pageInline, "doc-filled")
  }

  updateUI(target, icon) {
    this.swapIcon(target, icon);

    let pageNumber = this.pageNumber(target);

    if (this.printPageDetails(target)) {
      this.swapIcon(this.correspondingTextualtem(pageNumber), icon);
    } else if (this.printPageInline(target)) {
      this.swapIcon(this.correspondingGutterItem(pageNumber), icon);
    }
  }

//------------------------------------------------------------------------------
// General Helpers
//------------------------------------------------------------------------------

  correspondingGutterItem(pageNumber) {
    return this.contentCol.querySelector(
      `.printed-page-details[data-page="${pageNumber}"]`
    )
  }

  correspondingTextualtem(pageNumber){
    return this.contentCol.querySelector(
      `.printed-page-inline[data-page="${pageNumber}"]`
    )
  }

  pageMenu(target) {
    return target.querySelector(".page-menu")
  }

  pageNumber(el) {
    return el.dataset.page
  }

  printPageDetails(target) {
    return target.classList.contains("printed-page-details")
  }

  printPageInline(target) {
    return target.classList.contains("printed-page-inline")
  }

  printPageTarget(target) {
    return this.printPageDetails(target) || this.printPageInline(target)
  }

  swapIcon(target, replacementIcon) {
    let href = target.querySelector("use").getAttribute("xlink:href")

    target.classList.toggle("hover")
    target.querySelector("use").setAttribute("xlink:href",
      href.replace(/#\w+-?\w+/, `#${replacementIcon}`)
    )
  }

//------------------------------------------------------------------------------
// Templates
//------------------------------------------------------------------------------

  paragraphDetailsMenuMarkup(page, shortUrl, volume) {
    return this.paragraphDetailsMenuBox(`
      <p>
        The text following this element occurred on page ${page} of the
        print and PDF versions of this document.
      </p>

      <dl class="fr-list fr-list-inline">
        <dt>Page citation</dt>
        <dd>
          ${volume} FR ${page}

          <span class="copy-to-clipboard svg-tooltip" data-toggle="tooltip"
            data-title="Copy to Clipboard" data-title-copied="Copied to Clipboard"
            data-copy-text="${volume} FR ${page}">
            <svg class="svg-icon svg-icon-content-copy ">
              <use xlink:href="/assets/fr-icons.svg#content-copy"></use>
            </svg>
          </span>
        </dd>

        <dt>Page short url</dt>
        <dd>
          ${shortUrl}/page-${page}

          <span class="copy-to-clipboard svg-tooltip" data-toggle="tooltip"
            data-title="Copy to Clipboard" data-title-copied="Copied to Clipboard"
            data-copy-text="${shortUrl}/page-${page}">
            <svg class="svg-icon svg-icon-content-copy ">
              <use xlink:href="/assets/fr-icons.svg#content-copy"></use>
            </svg>
          </span>
        </dd>
      </dl>
    `)
  }

  paragraphDetailsMenuBox(menuHTML) {
    return `
      <div class="fr-box fr-box-published-alt no-footer page-menu-box">
        <div class="fr-seal-block fr-seal-block-header">
          <div class="fr-seal-content">
            <h6>Published Content - Printed Page</h6>
          </div>
        </div>
        <div class="content-block">
          ${menuHTML}
        </div>
        <div class="fr-seal-block fr-seal-block-footer"></div>
      </div>
    `
  }
}
