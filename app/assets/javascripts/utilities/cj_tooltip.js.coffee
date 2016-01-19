class @CJ.Tooltip

  @addTooltip: (selector, tooltipOptions)->
    tipsyOptions = {
      className: 'tooltip'
      title: ->
        $(this).data('tooltip')
      gravity: ->
        $(this).data('tooltip-gravity') || 's'
    }
    _.extend tipsyOptions, tooltipOptions

    $(selector)
      .tipsy tipsyOptions

  @addFancyTooltip: (selector, tooltipOptions, options)->
    tipsyOptions = {
      className: 'tooltip'
      title: ->
        $(this).data('tooltip')
      gravity: ->
        $(this).data('tooltip-gravity') || 's'
    }
    _.extend tipsyOptions, tooltipOptions

    options =  _.extend {}, options

    Tooltip = this

    $(selector)
      .tipsy tipsyOptions
      .mouseenter ->
        tooltip = $('.tipsy').first()
        el = $(this)

        Tooltip.calculateProperties(el, tooltip, options)
        Tooltip.positionTooltip(tooltip, options.position)


  @addFancySVGTooltip: (selector, tooltipOptions, options)->
    _.extend options, {svg: true}
    @addFancyTooltip(selector, tooltipOptions, options)


  @positionTooltip: (tooltip, position)->
    if position == 'centerTop'
      @positionCenterTop tooltip
    else if position == 'centerLeft'
      @positionCenterLeft tooltip
    else if position == 'centerRight'
      @positionCenterRight tooltip
    else if position == 'centerBottom'
      @positionCenterBottom tooltip


  @positionCenterTop: (tooltip)->
    tooltip
      .css(
        'left',
        Tooltip.elProperties.position.left + Tooltip.elProperties.width/2 - Tooltip.tooltipProperties.width/2 + Tooltip.offset.horizontal
      )
      .css(
        'top',
        Tooltip.elProperties.position.top - Tooltip.tooltipProperties.height + Tooltip.offset.vertical
      )

  @positionCenterLeft: (tooltip)->
    tooltip
      .css(
        'left',
        Tooltip.elProperties.position.left - Tooltip.tooltipProperties.width + Tooltip.offset.horizontal
      )
      .css(
        'top',
        Tooltip.elProperties.position.top + Tooltip.elProperties.height/2 - Tooltip.tooltipProperties.height/2 + Tooltip.offset.vertical
      )

  @positionCenterRight: (tooltip)->
    tooltip
      .css(
        'left',
        Tooltip.elProperties.position.left + Tooltip.elProperties.width + Tooltip.offset.horizontal
      )
      .css(
        'top',
        Tooltip.elProperties.position.top + Tooltip.elProperties.height/2 - Tooltip.tooltipProperties.height/2 + Tooltip.offset.vertical
      )

  @positionCenterBottom: (tooltip)->
    tooltip
      .css(
        'left',
        Tooltip.elProperties.position.left + Tooltip.elProperties.width/2 - Tooltip.tooltipProperties.width/2 + Tooltip.offset.horizontal
      )
      .css(
        'top',
        Tooltip.elProperties.position.top + Tooltip.elProperties.height + Tooltip.offset.vertical
      )

  @calculateProperties: (el, tooltip, options)->
    @offset = {
      horizontal: if options.horizontalOffset? then options.horizontalOffset else 0
      vertical: if options.verticalOffset? then options.verticalOffset else 0
    }

    @tooltipProperties = {
      height: tooltip.height(),
      width: tooltip.width(),
      position: tooltip.position()
    }

    if options.svg
      @elProperties = {
        height: el.attr('height'),
        width: el.attr('width'),
        position: el.offset()
      }
    else
      @elProperties = {
        height: el.height(),
        width: el.width(),
        position: el.offset()
      }
