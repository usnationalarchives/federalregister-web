$(document).ready ->
  $('.tooltip')
    .tipsy({
      gravity: ()->
        $(this).data('tooltip-gravity') || 's'
      fade: true
      offset: 0
      title: ()->
        $(this).data('tooltip')
      className: ()->
        $(this).data('tooltip-class') || ''

    })
    .mouseenter ()->
      tooltip = $('.tipsy').first()
      el = $(this)
      offset = 15 #this also needs to account for the tooltip arrow (>)

      tooltipHeight = tooltip.height()
      tooltipWidth = tooltip.width()
      tooltipPosition = tooltip.position()
      elHeight = el.height()
      elPosition = el.offset()

      tooltip
        .css(
          'left',
          elPosition.left - tooltipWidth - offset
        )
        .css(
          'top',
          elPosition.top - (tooltipHeight / 2) + (elHeight / 4)
        )
