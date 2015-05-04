$(document).ready ->
  printPageDisplayed = false

  $('.doc-nav-wrapper').delegate 'a#display-print-page', 'click', (event)->
    event.preventDefault()
    link = $(this)

    if printPageDisplayed
      link.
        text link.text().replace(/^Hide/, 'Display')
    else
      link.
        text link.text().replace(/^Display/, 'Hide')

    _.each $('.printed-page-wrapper.unprinted-element'), (el)->
      element = $(el)
      printedPage = element.find '.printed-page'

      if printPageDisplayed
        element
          .removeClass 'blocked'

        printedPage.text " "
      else
        element.addClass 'blocked'
        printedPage.text " Printed Page #{printedPage.data 'page'}"

    printPageDisplayed = !printPageDisplayed


  unprintedElementsDisplayed = false

  $('.doc-nav-wrapper').delegate 'a#display-unprinted-elements', 'click', (event)->
    event.preventDefault()

