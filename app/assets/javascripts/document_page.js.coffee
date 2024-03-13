$(document).ready ->
  #allow additional DOM elements for bootstrap popovers
  bootstrapDomElementWhitelist = $.fn.tooltip.Constructor.DEFAULTS.whiteList
  bootstrapDomElementWhitelist['dl'] = []
  bootstrapDomElementWhitelist['dt'] = []
  bootstrapDomElementWhitelist['dd'] = []
  bootstrapDomElementWhitelist['dd'] = []
  bootstrapDomElementWhitelist['dd'] = []
  bootstrapDomElementWhitelist.span = ['data-clipboard-text', 'data-tooltip']

  $('.bootstrap-popover').popover({
    container: '.bootstrap-scope',
    trigger: 'manual'
  })

  # Define utility function for converting Handlebars XSLT template names to the handlebars_assets gem convention
  CJ.convertTemplateNameToHandlebarsAssets =  (string) ->
    # eg convert something like '#regtext-auth-tooltip-template' => 'regtext-auth-tooltip'
    string.
      replace(/-/g,"_").
      replace("#","").
      replace("_template","").
      # Refactoring Opportunity: In lieu of doing manual filename replacements here, move handlebars templates in app/templates/documents to app/templates so this is no longer necessary.  Locally, there is some issue with the templates not re-registering in the correct location.
      replace("stars_5_tooltip","documents/stars_5_tooltip")


  if $('.doc-document .doc-content').length > 0
    $('.doc-content .content-col').tooltip({
      selector: '.svg-tooltip[data-toggle="tooltip"]'
    })
    (new OFR.CopyToClipboard).addTo(".doc-content")
    (new FR2.PrintPageElements).enable()

    tooltipOptions = {
      offset:  5
      opacity: 0.9
      delay:   0.3
      fade:    true
    }
    manager = new FR2.TableFixedHeaderManager(tooltipOptions)
    manager.perform()

    # currently only stars tooltip
    CJ.Tooltip.addFancyTooltip(
      $('.document-markup.cj-fancy-tooltip'),
      {
        className: ()->
          if $(this).data('tooltip-doc-override')
            docType = $(this).data('tooltip-doc-override')
          else if $('.document-markup.cj-fancy-tooltip').parents('.doc-official').length > 0
            docType = 'tooltip-doc-official'
          else
            docType = 'tooltip-doc-published'

          "document-markup-tooltip #{docType}"
        delay: 0.3
        fade: true
        gravity: 's'
        html: true
        opacity: 1
        title: ()->
          tooltipData = $(this).data('tooltip-data') || {}
          templateName = CJ.convertTemplateNameToHandlebarsAssets(
            $(this).data('tooltip-template')
          )
          HandlebarsTemplates[templateName]( tooltipData )
      },
      {
        position: 'centerTop'
        horizontalOffset: -10
        verticalOffset: -10
      }
    )

    # footnotes can have multiple references within the text. if you are
    # using the back to content link after having come from a reference,
    # we want to do our best to send you back where you came from
    $('.doc-content-area').delegate('.footnote .back', 'click', (event)->

      anchor = window.location.href.split('#')[1]
      footnoteId = $(this).closest('div.footnote').attr('id')

      if anchor != undefined && anchor == footnoteId
        event.preventDefault()
        window.history.back()
    )

    # utility nav items
    $('.doc-nav-wrapper a#email-a-friend').on 'click', (event)->
      event.preventDefault()
      emailAFriend = new FR2.EmailAFriend $(this).data('document-number')
      emailAFriend.display()

    commentButton = $('#start_comment')
    if commentButton.length > 0 && !$('#comment-bar').data('reggov-comment-url')
      if $('#addresses').length == 0
        if $('#further-info').length == 0
          commentButton.remove()
        else
          commentButton.attr('href', '#further-info')
