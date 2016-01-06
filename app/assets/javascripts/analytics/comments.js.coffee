class @FR2.Analytics
  @trackCommentEvent: (category, agency, documentNumber)=>
    @trackGAEvent category, agency, documentNumber

  @trackGAEvent: (category, action, label)->
    _gaq.push(
      ['_trackEvent', category, action, label]
    )

$(document).ready ->
  $('#comment-bar.comment').on 'click', '.button.formal_comment.how_to_comment', (e)->
    button = $(this)

    category = 'Comment: How to Comment'
    action = button.attr('href')
    documentNumber = button.closest('div.comment').data('document-number')

    @FR2.Analytics.trackGAEvent category, action, documentNumber
