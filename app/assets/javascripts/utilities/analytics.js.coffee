class @FR2.Analytics
  @trackCommentEvent: (category, agency, documentNumber)=>
    @trackGAEvent category, agency, documentNumber

  @trackGAEvent: (category, action, label)->
    # gtag('event', category, {'event_action': action, 'event_label': label})
