# Create an object to store non-persistent user data to
# Needs instantiation before document ready as some of these values
# are set by script tags in the html
FR2.currentUserStorage = new FR2.NonPersistentStorage()

$(document).ready ()->
  userData = new FR2.UserData()
  new FR2.UserNavigationManager(userData)

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

  # Subcription modals
  $('a.rss, a.subscription, a.subscription_action').not('.no-modal-action').on 'click', (e)->
    e.preventDefault()

    FR2.SubscriptionHandler.generateModal()

  # Document clipper(s)
  FR2.documentClippers = []
  _.each $('.document-clipping-actions'), (clipper)->
    FR2.documentClippers.push(new FR2.DocumentClipper(clipper))

  # Add space above navigation for user utils
  if $('.logo').siblings('div#user_utils').length > 0
    $('.logo .hgroup').css('position', 'relative').css('top', '20px')

  # External link modal
  $('body').on 'click', 'a:not(.formal_comment)', (e)->
    new FR2.ExternalLinkChecker(e)

  # Copy-to-clipboard links
  if $('.clipboard-copy').length > 0
    $('.clipboard-copy').on 'click', (e)->
      clipboard = new FR2.Clipboard
      successMessage = "Shorter document URL copied to clipboard"
      clipboard.copyToClipboard $(this).data('clipboardText')
      $('.tipsy .tipsy-inner').text(successMessage)


