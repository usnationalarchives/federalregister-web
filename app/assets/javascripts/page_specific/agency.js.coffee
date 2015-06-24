$(document).ready ()->
  agencyLogo = $('.agency-logo')

  $(agencyLogo).load ()->
    marginNeeded = agencyLogo.height() / 4

    $('.page-summary h1')
      .attr 'style', "margin-top: #{marginNeeded}px !important"

    agencyLogo
      .css 'margin-top', -marginNeeded
