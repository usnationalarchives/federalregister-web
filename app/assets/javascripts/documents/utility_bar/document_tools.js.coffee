$(document).ready ->
  $('.doc-nav-wrapper').delegate 'a#display-print-page', 'click', (event)->
    event.preventDefault()
    FR2.DocumentTools.togglePrintedPage $(this)


  $('.doc-nav-wrapper').delegate 'a#display-unprinted-elements', 'click', (event)->
    event.preventDefault()
    FR2.DocumentTools.toggleNonPrintedElements $(this)

class @FR2.DocumentTools

  @printPageDisplayed = false
  @nonPrintedElementsDisplayed = false

  @togglePrintedPage: (link)->
    @toggleLinkText link, @printPageDisplayed

    @toggleElements(
      $('.printed-page-wrapper.unprinted-element-wrapper'),
      @printPageDisplayed
    )

    @printPageDisplayed = !@printPageDisplayed


  @toggleNonPrintedElements: (link)->
    @toggleLinkText link, @nonPrintedElementsDisplayed

    @toggleElements(
      $('.unprinted-element-wrapper').not('.printed-page-wrapper'),
      @nonPrintedElementsDisplayed
    )

    @nonPrintedElementsDisplayed = !@nonPrintedElementsDisplayed


  @toggleLinkText: (link, displayed)->
    if displayed
      link.
        text link.text().replace(/^Hide/, 'Display')
    else
      link.
        text link.text().replace(/^Display/, 'Hide')

  @toggleElements: (elements, displayed)->
    _.each elements, (el)=>
      element = $(el)
      nonPrintedElement = element.find '.unprinted-element'

      if displayed
        element
          .removeClass 'blocked'

        nonPrintedElement.text " "
      else
        element.addClass 'blocked'
        nonPrintedElement.text " #{nonPrintedElement.data 'text'}"
        @setWrapperWidth(element)

  @setWrapperWidth: (element)->
    contentWrapEnforcementEl = $('.content-wrap-enforcement')

    wrapRange = {
      top: contentWrapEnforcementEl.offset().top
      bottom: contentWrapEnforcementEl.offset().top + contentWrapEnforcementEl.outerHeight()
    }

    if element.offset().top >= wrapRange.top && element.offset().top <= wrapRange.bottom
      element.addClass('content-wrap')
