class @FR2.Analytics
  @trackCommentEvent: (category, agency, documentNumber)=>
    @trackGAEvent category, agency, documentNumber

  @trackGAEvent: (category, action, label)->
    _gaq.push(
      ['_trackEvent', category, action, label]
    )
