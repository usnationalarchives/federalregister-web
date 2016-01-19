$(document).ready ()->
  # Clipboard helper
  $('.clippy').clippy({
    keep_text: true,
    clippy_path: '/assets/clippy.swf'
  })

  # Tooltips
  CJ.Tooltip.addTooltip(
    '.cj-tooltip',
    {
      offset: 5
      opacity: 0.9
      delay: 0.3
      fade: true
    }
  )

  # Toggle show/hides
  _.each $('.toggle'), (el)->
    new CJ.ToggleOne(el)

  _.each $('.toggle-all'), (el)->
    new CJ.ToggleAll(el)

  # Calendars
  standardCalendars = $('.calendar-wrapper:not(.cal-double) table.calendar')
  _.each standardCalendars, (calendar)->
    new FR2.Calendar $(calendar)

  multiCalendars = $('.calendars-wrapper')
  _.each multiCalendars, (wrapper)->
    new FR2.MultiCalendarHandler $(wrapper).find('table.calendar')

  # Analytics
  $('#comment-bar.comment').on 'click', '.button.formal_comment.how_to_comment', ->
    button = $(this)

    category = 'Comment: How to Comment'
    action = button.attr('href')
    documentNumber = button.closest('div.comment').data('document-number')

    FR2.Analytics.trackGAEvent category, action, documentNumber
