class @FR2.DocumentTools
  @unprintedElementsDisplayed = false
  @unprintedElementsSetup = false

  @toggleNonPrintedElements: (link)->
    @toggleLinkText link, @unprintedElementsDisplayed

    @toggleElements(
      $('.unprinted-element-wrapper').not('.printed-page-wrapper')
    )

    @resetUtilityBarHeight()

    @unprintedElementsDisplayed = !@unprintedElementsDisplayed

  @toggleLinkText: (link, displayed)->
    if displayed
      link.
        text link.text().replace(/^Hide/, 'Display')
    else
      link.
        text link.text().replace(/^Display/, 'Hide')

  @toggleElements: (elements)->
    if @unprintedElementsDisplayed
      _.each elements, (el)->
        $(el).hide()
    else
      _.each elements, (el)->
        $(el).css('display', 'block')

      if !@unprintedElementsSetup
        FR2.UnprintedElements.setup()
        @unprintedElementsSetup = !@unprintedElementsSetup

  @resetUtilityBarHeight: ->
    frBox = $('.doc-nav-wrapper').siblings('.fr-box').first()
    $('.doc-nav-wrapper').outerHeight(frBox.height() + 'px')

    $('.doc-document ul.doc-nav').sticky('refresh')
