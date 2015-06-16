$(document).ready ()->
  scroller = new FR2.CarouselScroller(
    $('.carousel-large .carousel-wrapper')
  )

  window.setTimeout( ()->
    scroller.show()
  , 300)
