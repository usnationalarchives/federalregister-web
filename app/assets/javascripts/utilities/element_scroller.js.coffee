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
    if !@elementWatcher.isInViewport && @containerWatcher.isInViewport
      if !@containerWatcher.isBelowViewport
        @el
          .css(
            'top',
            @containerWatcher.bottom - (@el.outerHeight() * 2) - @elementWatcher.offsets.bottom + 'px'
          )
      else if @containerWatcher.isBelowViewport
        @el
          .css(
            'top',
            @window.scrollTop() - @el.height() + 'px'
          )
          # scrollMonitor.viewportTop doesn't seem to always be a valid value
          # at this point in the loading, so using window.scrollTop() instead

      @debugMessage = "Element not in viewport"

  attachContainerWatcherEvents: ()->
    @containerWatcher.partiallyExitViewport ()=>
      if @currentScrollDirection == 'up' && !@elementWatcher.isAboveViewport
        @el
          .removeClass 'fixed'
          .css('top', 'auto') # reset nav top
        @elementWatcher.recalculateLocation()

        @debugMessage = 'Container has partially left the top viewport'

      else if @currentScrollDirection == 'down' && !@elementWatcher.isBelowViewport
        @elementWatcher.recalculateLocation()
        @el
          .css(
            'top',
            @elementWatcher.top - @el.outerHeight() + 'px'#- @elementWatcher.offsets.bottom
          )
          .removeClass 'fixed'
        @debugMessage = 'Container has partially left the bottom viewport'


  attachElementWatcherEvents: ()->
    @elementWatcher.enterViewport ()=>
      @debugMessage = 'I have entered the viewport'


    @elementWatcher.fullyEnterViewport ()=>
      @debugMessage = 'I have fully entered the viewport'


    @elementWatcher.partiallyExitViewport ()=>
      if @currentScrollDirection == 'down' && !@elementWatcher.isBelowViewport && @containerWatcher.isBelowViewport
        @el
          .addClass 'fixed'
          .css(
            'top',
            $(window).height() - @el.outerHeight() - @elementWatcher.offsets.bottom + 'px'
          )

        @debugMessage = 'I have partially left the top viewport'
      else if @currentScrollDirection == 'up' && !@elementWatcher.isAboveViewport
        @el
          .addClass 'fixed'
          .css 'top', '0px'
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
            @el
              .css(
                'top',
                 @elementWatcher.top - @el.outerHeight() + 78 + 'px'
              )
              .removeClass 'fixed'
          else if @currentScrollDirection == 'down'
            @el
              .css(
                'top',
                 @elementWatcher.top - scrollMonitor.viewportHeight
              )
              .removeClass 'fixed'

          @debugMessage = "Scroll direction changed, direction: #{@currentScrollDirection}, removing class='fixed'"

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
