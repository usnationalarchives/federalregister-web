class @FR2.TableFixedHeaderHandler
  constructor: (table, isSafari=false, thBackgroundColor="rgb(241, 241, 241)")->
    @table             = $(table)
    @isSafari          = isSafari
    @thBackgroundColor = thBackgroundColor

  perform: ->
    this._adjustThCss()

  _adjustThCss: ->
    context = this
    theadHeight = this.table.find('tr').first().offset().top

    captionHeightAdjustment = 0
    if this.isSafari
      caption = this.table.find('caption')
      if caption.length > 0
        captionHeightAdjustment = caption.outerHeight(true)

    this.table.find('th').each (index) ->
      topValue = $(this).offset().top - theadHeight - captionHeightAdjustment
      $(this).css 'top', topValue
      $(this).css 'background-color', context.thBackgroundColor
