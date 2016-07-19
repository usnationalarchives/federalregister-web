class @FR2.UnprintedElements
  @docDetailsHeight: ->
    $('.doc-aside.doc-details').height()

  @unprintedElements: ->
    $('.unprinted-element-wrapper').not('.printed-page-wrapper')

  @setup: ->
    @positionElements()

  # The gutter at the  top of the document page is occupied by
  # the document details bar. Print page elements in this area need
  # to be displayed inline with the text as block level elements.
  @positionElements: ->
    _.each @unprintedElements(), (el)=>
      el = $(el)
      if el.position().top < @docDetailsHeight()
        el.addClass('blocked')
