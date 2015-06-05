class @CarouselScroller
  constructor: (carousel)->
    @carousel = $(carousel)
    @nav = @carousel.find('.carousel-nav')

    # Used for navigation behaviors
    @firstPage = 0
    @lastPage = @carousel.find('.carousel-scroller > ul li').size() - 1

    # need to pass a single carousel instance not a jQuery set
    @carouselScroller = @createScroller(@carousel.get(0), @scrollerDefaults())

    @attachScrollerBehavior()
    @attachNavBehavior()
    @setupCarouselItems()

  createScroller: (carousel, options)->
    new IScroll(carousel, options)

  scrollerDefaults: ()->
    {
      # turn off momentum animation - improves performance
      momentum: false
      # set allowable scrolls (opposite of defaults)
      scrollX: true
      scrollY: false
      # snap to each li in our carousel
      snap: 'li'
    }

  attachScrollerBehavior: ()->
    scroller = this

    @carouselScroller.on 'scrollStart', ()->
      scroller.onScrollStart()

    @carouselScroller.on 'scrollEnd', ()->
      scroller.onScrollEnd(this)

  onScrollStart: ()->
    # Turn off all indicators
    indicators = this.carousel.find ".indicator li"

    _.each indicators, (indicator)->
      $(indicator).removeClass 'active'

  onScrollEnd: (carouselScroller)=>
    # Set the proper indicator to active
    indicators = this.carousel.find ".indicator li"

    selectedIndicator = _.find indicators, (indicator)->
      $(indicator).data('carousel-page') == carouselScroller.currentPage.pageX

    $(selectedIndicator).addClass 'active'

  attachNavBehavior: ()->
    # Previous arrow behavior
    @nav.on 'click', '.prev', (event)=>
      if @carouselScroller.currentPage.pageX != @firstPage
        @carouselScroller.prev()
        @onScrollStart()

    # Next arrow behavior
    @nav.on 'click', '.next', (event)=>
      if @carouselScroller.currentPage.pageX != @lastPage
        @carouselScroller.next()
        @onScrollStart()

    # Each indicator should take you directly to it's item
    scroller = this
    @nav.on 'click', 'li', (event)->
      page = $(this).data('carousel-page')

      if scroller.carouselScroller.currentPage.pageX != page
        scroller.carouselScroller.goToPage(page, 0)
        scroller.onScrollStart()

  setupCarouselItems: ()->
    # Each item needs some behaviors added so we create an instance for each
    _.each @carousel.find('.carousel-rounded-box'), (box)=>
      new CarouselItem(box, this)

class @CarouselItem
  textWrapperBgPadding = 10
  attributionBgPadding = 5

  constructor: (box, parent)->
    @box = $(box)
    @parent = parent
    @attachBehavior()

  attachBehavior: ()->
    # The width and height of the backgrounds need to be set once
    # the page has rendered. Because most of our carousel items are
    # hidden on page load iScroll can't get thier true sizes. We refresh
    # iScroll once here and then set them.
    @box.on 'show', ()=>
      if !@box.data('setup-complete')
        @parent.carouselScroller.refresh()

        textWrapper = @box.find('.text-wrapper')
        textWrapperBg = @box.find('.text-wrapper-bg')

        textWrapperBg
          .css 'height', textWrapper.height() + textWrapperBgPadding
          .css 'width', textWrapper.width() + textWrapperBgPadding

        attribution = @box.find('.attribution')
        attributionBg = @box.find('.attribution-bg')

        attributionBg
          .css 'height', attribution.height()
          .css 'width', attribution.width() + attributionBgPadding

        @box.data('setup-complete', true)
