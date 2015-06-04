class @CarouselScroller
  constructor: (carousel)->
    @carousel = $(carousel)
    @nav = @carousel.find('.carousel-nav')

    @firstPage = 0
    @lastPage = @carousel.find('.carousel-scroller > ul li').size() - 1

    # need to pass a single carousel instance not a jQuery set
    @carouselScroller = @createScroller(@carousel.get(0), @scrollerDefaults())

    @attachScrollerBehavior()
    @attachNavBehavior()

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
    indicators = this.carousel.find ".indicator li"

    _.each indicators, (indicator)->
      $(indicator).removeClass 'active'

  onScrollEnd: (carouselScroller)=>
    indicators = this.carousel.find ".indicator li"

    selectedIndicator = _.find indicators, (indicator)->
      $(indicator).data('carousel-page') == carouselScroller.currentPage.pageX

    $(selectedIndicator).addClass 'active'

  attachNavBehavior: ()->
    @nav.on 'click', '.prev', (event)=>
      if @carouselScroller.currentPage.pageX != @firstPage
        @carouselScroller.prev()
        @onScrollStart()

    @nav.on 'click', '.next', (event)=>
      if @carouselScroller.currentPage.pageX != @lastPage
        @carouselScroller.next()
        @onScrollStart()

    scroller = this
    @nav.on 'click', 'li', (event)->
      page = $(this).data('carousel-page')

      if scroller.carouselScroller.currentPage.pageX != page
        scroller.carouselScroller.goToPage(page, 0)
        scroller.onScrollStart()



class @CarouselBox
  textWrapperBgPadding = 10
  attributionBgPadding = 5

  constructor: (box)->
    @box = $(box)
    @attachBehavior()

  attachBehavior: ()->
    # the width and height of the backgrounds need to be set once
    # the page has rendered. so we do it once here the first time we
    # show the content
    @box.on 'show', ()=>
      if !@box.data('setup-complete')
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
