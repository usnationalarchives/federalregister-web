class @FR2.ElementScroller
  constructor: (@el, options)->
    @window = $(window)
    @previousScrollLocation = @window.scrollTop()
    @scrollThrottle = 100 #ms

    @debug = options.debug
    @debugMessage = null

    @elementWatcher = scrollMonitor.create(
      @el,
      options.offsets
    )

    $(document).on 'keydown', null, 'meta+down', =>
      scrollMonitor.recalculateLocations()

    $(document).on 'keydown', null, 'meta+up', =>
      scrollMonitor.recalculateLocations()

    @attachElementWatcherEvents()

    if options.container
      @containerWatcher = scrollMonitor.create(
        options.container.el,
        options.container.offsets
      )
      @attachContainerWatcherEvents()

      @ensureElementInViewport()

    @displayDebugMessage()

  ensureElementInViewport: ()->
    scrollMonitor.recalculateLocations()
    $(window).trigger('scroll')

    if @containerWatcher.isInViewport
      if @containerWatcher.isBelowViewport
        @el
          .css(
            'top',
            scrollMonitor.viewportTop + 'px'
          )
      else if !@containerWatcher.isBelowViewport
        @el
          .css(
            'top',
            @containerWatcher.bottom - (@el.outerHeight() * 2) - @elementWatcher.offsets.bottom + 'px'
          )

      @debugMessage = "Element not in viewport"
    else
      @debugMessage = "Container not in viewport"

  attachContainerWatcherEvents: ()->
    @containerWatcher.fullyEnterViewport ()=>
      if @currentScrollDirection == 'up'
        @el
          .addClass 'fixed'
          .css 'top', '0'
        @elementWatcher.recalculateLocation()

        @debugMessage = 'Container has fully entered viewport'

    @containerWatcher.partiallyExitViewport ()=>
      @debugMessage = "{scroll: #{@currentScrollDirection},
        elAbove: #{@elementWatcher.isAboveViewport},
        elBelow: #{@elementWatcher.isBelowViewport},
        containerAbove: #{@containerWatcher.isAboveViewport},
        containerBelow: #{@containerWatcher.isBelowViewport}}"

      if @currentScrollDirection == 'up' && !@elementWatcher.isAboveViewport
        # reset nav top
        @el
          .removeClass 'fixed'
          .css('top', -10)
        @elementWatcher.recalculateLocation()

        @debugMessage = 'Container has partially left the top viewport'

      else if @currentScrollDirection == 'down' && !@containerWatcher.isBelowViewport
        @elementWatcher.recalculateLocation()
        top = @containerWatcher.bottom - (@el.outerHeight() * 2) - @elementWatcher.offsets.bottom + 'px'

        @el.css('top', top).removeClass('fixed')

        @debugMessage = "{top: #{top}, containerBottom: #{@containerWatcher.bottom}}"
        @debugMessage = 'Container has partially left the bottom viewport'


  attachElementWatcherEvents: ()->
    @elementWatcher.enterViewport ()=>
      @debugMessage = 'I have entered the viewport'


    @elementWatcher.fullyEnterViewport ()=>
      @debugMessage = 'I have fully entered the viewport'


    @elementWatcher.partiallyExitViewport ()=>
      if @currentScrollDirection == 'down' && !@elementWatcher.isBelowViewport && @containerWatcher.isBelowViewport
        if @elementWatcher.isAboveViewport
          top = $(window).height() - @el.outerHeight() - @elementWatcher.offsets.bottom + 'px'
        else
          top = 0

        @el.addClass('fixed').css('top', top)

        @debugMessage = "I have partially left the top viewport. {class: fixed, top: #{top}}"
      else if @currentScrollDirection == 'up' && !@elementWatcher.isAboveViewport && @containerWatcher.isBelowViewport
        @el
          .addClass 'fixed'
          .css 'top', '0'
        @elementWatcher.recalculateLocation()

        @debugMessage = 'I have partially left the bottom viewport'


    # watch the page scroll so that we know the direction the page
    # is currently scrolling
    _.throttle(
      @window.on("scroll", ()=>
        @scrollDirection()

        if @scrollDirectionChanged && @el.hasClass('fixed')
          @elementWatcher.recalculateLocation()

          if @currentScrollDirection == 'up'
            top = @elementWatcher.top - @el.outerHeight() + 25 + 'px'
          else if @currentScrollDirection == 'down'
            top = @elementWatcher.top - scrollMonitor.viewportHeight + 25 + 'px'

          @el.css('top', top).removeClass('fixed')

          @debugMessage = "Scroll direction changed, removing 'fixed' class. {direction: #{@currentScrollDirection}, top: #{top}}"

        @displayDebugMessage()
      ),
      @scrollThrottle
    )

    @elementWatcher

  #returns whether the page is being scrolled up or down
  scrollDirection: ()->
    @currentScrollLocation = @window.scrollTop()

    if @currentScrollLocation > @previousScrollLocation
      @currentScrollDirection = 'down'
    else
      @currentScrollDirection = 'up'

    if @previousScrollDirection
      @scrollDirectionChanged = @currentScrollDirection != @previousScrollDirection
    else
      @scrollDirectionChanged = true

    @previousScrollDirection = @currentScrollDirection
    @previousScrollLocation = @currentScrollLocation

  displayDebugMessage: ()->
    if @debug && @debugMessage
      console.log @debugMessage
      @debugMessage = null
