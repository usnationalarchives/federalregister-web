class @FR2.UtilityNav
  constructor: (content)->
    # @navWrapper = $(navWrapper)
    # @contentWrapper = $(contentWrapper)
    @content = $(content)
    @navWrapper = $(@content.find('.content-nav-wrapper'))
    @contentWrapper = $(@content.find('.content-col'))
    @nav = @navWrapper.find('.content-nav')
    @navElements = @nav.find('> li:not(.button)')
    @addEvents()

  addEvents: ->
    @initializeUtilityNav()
    @addToggleWidthEvent()
    @addSticky()
    @addNavElementEvents()
    @addResizeWindowEvent()

  addNavElementEvents: ->
    @addElementClickEvents()

  initializeUtilityNav: ->
    @addResizeUtilityNavEvent()
    settings = FR2.UserPreferenceStore.getAllUtilityNavSettings()
    @setNavSize(settings["width"])

  # set the height of the nav wrapper after we've loaded
  # otherwise the height won't be correct
  addResizeUtilityNavEvent: ->
    # ideally we don't want a timeout here but semantic-ui sticky
    # makes the wrapper bigger than it should be - so we wait for it
    # to finish before fixing.
    setTimeout(
      =>
        contentBox = @navWrapper.siblings('.content-col').first()
        @navWrapper.outerHeight(contentBox.outerHeight() + 'px')
      1500
    )

  addResizeWindowEvent: ->
    $(window).on "resizeEnd", =>
      @refresh()

  refresh: =>
    @nav.sticky('refresh')
    @setNavDropdownPositions()

  addToggleWidthEvent: ->
    button = @navWrapper.find('.content-nav-compress-toggle')
    button.on 'click', =>
      if @content.hasClass('wide-utility-nav')
        @setNavSize("narrow")
        FR2.UserPreferenceStore.saveUtilityNavSetting("width": "narrow")
      else if @content.hasClass('narrow-utility-nav')
        @setNavSize("wide")
        FR2.UserPreferenceStore.saveUtilityNavSetting("width": "wide")

      @nav.sticky('refresh')

  setNavSize: (value)->
    if value == "narrow"
      @content.removeClass('wide-utility-nav')
      @content.addClass('narrow-utility-nav')
      @setUtilityNavTooltips('add')
    else if value == "wide"
      @content.removeClass('narrow-utility-nav')
      @content.addClass('wide-utility-nav')
      @setUtilityNavTooltips('remove')

    @setNavDropdownPositions()

  setNavDropdownPositions: ->
    # delay needed to ensure new nav width has been painted
    setTimeout(
      =>
        @nav.find('.dropdown-menu').css('left', @nav.outerWidth())
      1000
    )

  setUtilityNavTooltips: (action)->
    if action == 'add'
      @nav.tooltip({
        selector: '> li > .svg-tooltip[data-toggle="tooltip"]'
      })
    else if action == 'remove'
      @nav.tooltip('destroy', {
        selector: '> li > .svg-tooltip[data-toggle="tooltip"]'
      })

  addSticky: ->
    context = "." + @navWrapper.parents('.with-utility-nav')
      .attr('class').split(' ').join('.')

    @nav.sticky({
      context: context,
      offset: 0
    })

  addPrintOnClickEvent: ->
    printLink = @navWrapper.find('.print-content')
    printLink.on 'click', (e) =>
      e.preventDefault()
      window.print()

  ######################
  # NAV ELEMENTS (LI's)
  ######################

  addElementClickEvents: ->
    @navElements.not('.disabled').on('click tap', (event)=>
      navEl = $(event.target).closest('li')
      # if we're clicking on an open item close it
      # but not if we're clicking on an item in the open menu portion
      if navEl.hasClass('open') && (
          navEl == event.target || !$(event.target).parents('.dropdown-menu').length
        ) && !$(event.target).hasClass('toggle')
        navEl.removeClass('open')
        @updateTextBlur("remove")
      else if $(event.target).data('close-utility-nav')
        @closeAllNavElements()
      else
        navEl.addClass('open')
          .siblings('.open').removeClass('open')
        @updateTextBlur("add")

      event.stopPropagation()
    )

    # close dropdown if we click outside the dropdown menu
    $('body').on 'click tap', (event)=>
      target = $(event.target)
      @navElements
        # filter out this navElement if it's the one we just opened
        # the 'body' event will bubble up last so we've already opened the menu
        .filter ()->
          target[0] != this && target.parents('li.open')[0] != this
        .removeClass('open')

      @updateTextBlur("remove")

  updateTextBlur: (action)->
    contentBlock = @contentWrapper.find('> .fr-box > .content-block')
    if action == "remove"
      contentBlock.removeClass('blur')
    else
      contentBlock.addClass('blur')

  closeAllNavElements: ->
    @navElements.removeClass('open')
    @updateTextBlur("remove")
