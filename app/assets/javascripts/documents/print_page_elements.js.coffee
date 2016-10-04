class @FR2.PrintPageElements
  @docDetailsHeight: ->
    $('.doc-aside.doc-details').height()

  @printPageElements: ->
    $('.printed-page-wrapper')

  @printPageIcons: ->
    $(".printed-page-inline")

  @pageNumber: (el)->
    el.find('.printed-page').data('page')

  @correspondingIcon: (pageNumber)->
    $(".printed-page-inline[data-page=#{pageNumber}]")

  @correspondingGutterItem: (pageNumber)->
    $(".printed-page-wrapper .printed-page[data-page=#{pageNumber}]")
      .closest('.printed-page-wrapper')

  @setup: ->
    @positionElements()
    @addUIEvents()

  # The gutter at the  top of the document page is occupied by
  # the document details bar. Print page elements in this area need
  # to be displayed inline with the text as block level elements.
  @positionElements: ->
    @blockElements()
    @alignGutterElements()

  @blockElements: ->
    _.each @printPageElements(), (el)=>
      el = $(el)

      # paragraph's are set to 'position: relative' and so if an element
      # is within a paragraph we want to add it's 'top' to the paragraph's 'top'
      # to get the elements true position within the body text
      if el.parents('p').length > 0
        top = el.parents('p').position().top + el.position().top
      else
        top = el.position().top

      if top < @docDetailsHeight()
        el.addClass('blocked')

        inlineEl = @correspondingIcon @pageNumber(el)
        inlineEl.remove()

  @alignGutterElements: ->
    _.each @printPageIcons(), (inlineEl)=>
      gutterItem = @correspondingGutterItem(
        $(inlineEl).data('page')
      )

      gutterItem.css(
        'top',
        $(inlineEl).position().top - gutterItem.position().top
      )

  @addUIEvents: ->
    printPageElements = this

    @printPageElements().not('.blocked').on 'mouseenter', (event)->
      event.stopPropagation()
      
      $(this).addClass('hover')

      printPageElements.correspondingIcon(
        printPageElements.pageNumber $(this)
      )
      .addClass('hover')
      .addClass('icon-fr2-doc_filled')
      .removeClass('icon-fr2-doc-generic')


    @printPageElements().not('.blocked').on 'mouseleave', ->
      $(this).removeClass('hover')

      printPageElements.correspondingIcon(
        printPageElements.pageNumber $(this)
      )
      .removeClass('hover')
      .removeClass('icon-fr2-doc_filled')
      .addClass('icon-fr2-doc-generic')


    @printPageIcons().on 'mouseenter', ->
      $(this).addClass('hover')
        .addClass('icon-fr2-doc_filled')
        .removeClass('icon-fr2-doc-generic')

      gutterItem = printPageElements.correspondingGutterItem(
        $(this).data('page')
      )

      gutterItem.addClass('hover')
      gutterItem
        .find('.printed-page')
        .trigger('mouseenter')
      gutterItem
        .find('.icon-fr2')
        .addClass('icon-fr2-doc_filled')
        .removeClass('icon-fr2-doc-generic')


    @printPageIcons().on 'mouseleave', ->
      $(this).removeClass('hover')
        .removeClass('icon-fr2-doc_filled')
        .addClass('icon-fr2-doc-generic')

      gutterItem = printPageElements.correspondingGutterItem(
        $(this).data('page')
      )

      gutterItem.removeClass('hover')
      gutterItem
        .find('.printed-page')
        .trigger('mouseleave')
      gutterItem
        .find('.icon-fr2')
        .removeClass('icon-fr2-doc_filled')
        .addClass('icon-fr2-doc-generic')
