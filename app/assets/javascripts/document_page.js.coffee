$(document).ready ->
  if $('.doc-document .doc-content').length > 0
    # properly position unprinted elements based on their location in the
    # document and events after fonts have loaded
    if $('html').hasClass('wf-active')
      FR2.PrintPageElements.setup()
      FR2.UnprintedElements.setup()
    else
      $('body').on 'typekit-active', ->
        FR2.PrintPageElements.setup()
        FR2.UnprintedElements.setup()

    # setup sidbar positioning
    document_height = $('.doc-document .doc-content').outerHeight()
    sidebar_height = $('.doc-aside.doc-details').outerHeight()
    amount_document_should_be_lower_than_sidebar = 50
    side_bar_top_offset = 30

    if document_height < sidebar_height + amount_document_should_be_lower_than_sidebar
      $('.doc-content .fr-box')
        .css(
          'height',
          sidebar_height + amount_document_should_be_lower_than_sidebar + side_bar_top_offset
        )

    CJ.Tooltip.addFancyTooltip(
      $('.document-markup.cj-fancy-tooltip'),
      {
        className: ()->
          if $(this).data('tooltip-doc-override')
            docType = $(this).data('tooltip-doc-override')
          else if $('.document-markup.cj-fancy-tooltip').parents('.doc-official').size() > 0
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
