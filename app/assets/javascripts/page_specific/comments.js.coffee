$(document).ready ->
  $('#comments .tooltip.agency-not-participating')
    .tipsy({
      gravity: 'e'
      fade: true
      offset: 2
      title: ->
        $(this).data 'tooltip'
      className: ->
        $(this).data 'tooltip-class'
    })
    .mouseenter ()->
      tooltip = $('.tipsy.agency-not-participating').first()

      tooltip
        .css(
          'left',
          tooltip
            .position()
            .left + 395
        )
        .css(
          'top',
          tooltip
            .position()
            .top - 21
        )
