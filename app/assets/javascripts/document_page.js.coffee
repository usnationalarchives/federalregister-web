$(document).ready ->
  #allow additional DOM elements for bootstrap popovers
  bootstrapDomElementWhitelist = $.fn.tooltip.Constructor.DEFAULTS.whiteList
  bootstrapDomElementWhitelist['dl'] = []
  bootstrapDomElementWhitelist['dt'] = []
  bootstrapDomElementWhitelist['dd'] = []
  bootstrapDomElementWhitelist['dd'] = []
  bootstrapDomElementWhitelist['dd'] = []
  bootstrapDomElementWhitelist.span = ['data-clipboard-text', 'data-tooltip']

  $('.bootstrap-popover').popover({container: '.bootstrap-scope', trigger: 'manual'})

  # This is used to enable event delegation-based clipboard copying
  $( "body" ).on "click", '.copy-to-clipboard', (event) ->
    event.preventDefault()
    clipboard = new FR2.Clipboard
    clipboard.copyToClipboard $(this).data('clipboardText')
    $('.tipsy .tipsy-inner').text('Selection copied to clipboard')
  # ***************************

  if $('.doc-document .doc-content').length > 0
    # properly position unprinted elements based on their location in the
    # document and events after fonts have loaded
    FR2.PrintPageElements.setup()
    FR2.UnprintedElements.setup()

    # setup sidbar positioning
    document_height = $('.doc-document .doc-content').outerHeight()
    sidebar_height = $('.doc-aside.doc-details').outerHeight()
    amount_document_should_be_lower_than_sidebar = 50
    side_bar_top_offset = 30

    fullTextAvailable = $('.doc-nav-wrapper .icon-fr2-print').length > 0
    if fullTextAvailable && (document_height < sidebar_height + amount_document_should_be_lower_than_sidebar)
      $('.doc-content .fr-box')
        .css(
          'height',
          sidebar_height + amount_document_should_be_lower_than_sidebar + side_bar_top_offset
        )

    $(".bootstrap-popover").on "click", (event) ->
      event.preventDefault()
      tooltipData = $(this).data('tooltip-data') || {}

      if $(this).hasClass('printed-page')
        tooltipData['shortUrl'] = $('#fulltext_content_area').data('short-url')

        if $('#document-citation').data('citation-vol')
          tooltipData['volume'] = $('#document-citation').data('citation-vol')

      isVisible = $(this).data('bs.popover').tip().hasClass('in')
      if isVisible
        $(this).popover('hide')
      else
        $(this).data('bs.popover').options.content = Handlebars.compile(
          $( $(this).data('tooltip-template') ).html()
        )( tooltipData )
        $(this).popover('show')
        #The tooltips have to be reinitialized since the tipsy element isn't in the DOM yet
        CJ.Tooltip.addTooltip(
          '.cj-tooltip',
          {
            offset: 5
            opacity: 0.9
            delay: 0.3
            fade: true
          }
        )


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

          if $(this).hasClass('printed-page')
            tooltipData['shortUrl'] = $('#fulltext_content_area').data('short-url')

            if $('#document-citation').data('citation-vol')
              tooltipData['volume'] = $('#document-citation').data('citation-vol')


          Handlebars.compile(
            $( $(this).data('tooltip-template') ).html()
          )( tooltipData )
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
    $('.doc-nav-wrapper a#display-unprinted-elements').on 'click', (event)->
      event.preventDefault()
      FR2.DocumentTools.toggleNonPrintedElements $(this)

    $('.doc-nav-wrapper a#email-a-friend').on 'click', (event)->
      event.preventDefault()
      emailAFriend = new FR2.EmailAFriend $(this).data('document-number')
      emailAFriend.display()

    commentButton = $('#start_comment')
    if commentButton.length > 0 && !$('#comment-bar').data('reggov-comment-url')
      if $('#addresses').length == 0
        if $('#further-info').length == 0
          commentButton.remove()

          # disable utility nav items also
          utilityNavComment = $('#utility-nav-formal-comment')
          utilityNavComment.addClass('unavailable')
          utilityNavComment.find('.fr-box.dropdown-menu')
            .removeClass('fr-box-enhanced')
            .addClass('disabled')
          utilityNavComment.find('li').text('This feature is not available for this document.')

          utilityNavReadComments = $('#utility-nav-public-comments')
          utilityNavReadComments.addClass('unavailable')
          utilityNavReadComments.find('.fr-box.dropdown-menu')
            .removeClass('fr-box-enhanced')
            .addClass('disabled')
          utilityNavReadComments.find('li').text('This feature is not available for this document.')
        else
          commentButton.attr('href', '#further-info')
          $('#utility-nav-comment-link').attr('href', '#further-info')
