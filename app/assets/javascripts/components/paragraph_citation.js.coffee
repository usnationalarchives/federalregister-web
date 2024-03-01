# When a user interacts with (hover or tap) a citable element (like a
# paragraph, etc.) we want to display a bookmark icon to indicate that it is
# citable.
# When the user then interacts with that bookmark we want to highlight the
# citable element and allow them to click to copy that url (and update the
# current url in the browser url bar).
# Rather than creating new icon and background elements on each interaction,
# we use existing elements and move them around the DOM.

class @FR2.ParagraphCitation
  constructor: (@contentArea)->
    @addEvents()
    @cb = new FR2.Clipboard

  addEvents: ->
    @addTooltip()
    @enterElement()
    @enterIcon()
    @leaveElement()

    @clickIcon()

  citationTargetEls: ->
    '*[id^=p-]'

  singleLineHeight:
    27

  icon: ->
    $('.citation-target-icon')

  background: ->
    $('.citation-target-background')

  addTooltip: ->
    CJ.Tooltip.addFancyTooltip(
      @icon(),
      {
        className: 'paragraph-citation-tooltip'
        delay: 0.3
        fade: true
        gravity: 'w'
        opacity: 1
      },
      {
        horizontalOffset: -3
        position: 'centerRight'
        verticalOffset: -8
      }
    )

  enterElement: ->
    @contentArea.on 'mouseenter tap', @citationTargetEls(), (event)=>
      if event.target.closest(".printed-page-details")
        return

      paragraph = $(event.currentTarget)

      # clean up in case of tap event (eg no mouseleave from previous element)
      if !paragraph.hasClass('citation-hover-present')
        @background().hide()
        @icon().hide()

        # mark paragraph as being interacted with
        paragraph.addClass('citation-hover-present')

        # if the target is a single line add a class so that it can be styled properly
        if paragraph.height() <= @singleLineHeight
          paragraph.addClass('single-line')

        if paragraph.hasClass('amendment-part') && paragraph.find('.amendment-part-subnumber').length
          paragraph.addClass('amdpar-subnumber-present')

        # set the current element as the target for later use
        @icon().data('citation-target', '#' + paragraph.attr('id'))

        # add icon and display
        @moveIconTo(paragraph)
        @icon().show()


  enterIcon: ->
    @contentArea.on 'mouseenter tap', '.citation-target-icon', =>
      # get reference
      target = $(@icon().data('citation-target'))

      # position background and make visible
      @moveBackgroundTo(target)
      @background().css(
        'height',
        target.height() +
          parseInt(@background().css('padding-top')) +
          parseInt(@background().css('padding-bottom'))
      )

      if @background().parent('p').hasClass('amendment-part')
        bgPadding = 58
      else
        bgPadding = 38

      @background().css('width', target.width() + bgPadding)
      @background().show()

  leaveElement: ->
    @contentArea.on 'mouseleave', @citationTargetEls(), (event)=>
      # get reference
      el = $(event.currentTarget)

      # hide background and icon
      @background().hide()
      @icon().hide()

      # remove the class that is designating interaction
      el.removeClass('citation-hover-present')

  clickIcon: ->
    @contentArea.on 'click tap', '.citation-target-icon', =>
      @copyUrlToClipboard()
      @setTooltipSuccessMessage()

  moveBackgroundTo: (el)->
    el.append(
      $('.citation-target-background')
    )

  moveIconTo: (el)->
    el.prepend(
      $('.citation-target-icon')
    )

  copyUrlToClipboard: ->
    @cb.copyToClipboard @citationUrl()

  citationUrl: ->
    "#{@icon().data('short-url')}/#{@icon().data('citation-target').slice(1)}"

  setTooltipSuccessMessage: ->
    $('.tipsy .tipsy-inner')
      .text("Citation copied to clipboard")
