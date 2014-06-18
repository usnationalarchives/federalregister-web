class @FR2.Analytics
  @trackCommentEvent: (category, agency, documentNumber)->
    _gaq.push(
      ['_trackEvent', category, agency, documentNumber]
    )

$(document).ready ->
  $('#flash_message.comment').on 'click', '.button.formal_comment.how_to_comment', (e)->
    button = $(this)

    category = 'Comment: How to Comment'
    agency = button.closest('div.comment').data('reggov-agency')
    documentNumber = button.closest('div.comment').data('document-number')

    @FR2.Analytics.trackCommentEvent category, agency, documentNumber
