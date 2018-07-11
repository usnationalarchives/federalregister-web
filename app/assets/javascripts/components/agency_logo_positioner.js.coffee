class @FR2.AgencyLogoPositioner
  constructor: ->
    @addEvents()

  addEvents: ->
    $('.agency-logo').Lazy(
      afterLoad: (agencyLogo)->
        marginNeeded = agencyLogo.height() / 4

        $('.agency-header h1')
          .attr('style', "margin-top: #{marginNeeded}px !important")

        agencyLogo.css('margin-top', -marginNeeded)
        agencyLogo.removeClass('loading')
        
      onError: (agencyLogo)->
        agencyLogo.hide()
    )
