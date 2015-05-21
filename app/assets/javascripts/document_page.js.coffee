$(document).ready ->
  if $('.doc-official .doc-content').length > 0
    document_height = $('.doc-official .doc-content').outerHeight()
    sidebar_height = $('.doc-aside.doc-details').outerHeight()
    amount_document_should_be_lower_than_sidebar = 50
    side_bar_top_offset = 30

    if document_height < sidebar_height + amount_document_should_be_lower_than_sidebar
      $('.doc-content .fr-box.fr-box-official')
        .css(
          'height',
          sidebar_height + amount_document_should_be_lower_than_sidebar + side_bar_top_offset
        )

    CJ.Tooltip.addFancyTooltip(
      $('.document-markup.cj-fancy-tooltip'),
      {
        className: 'document-markup-tooltip'
        delay: 0.3
        fade: true
        gravity: 's'
        html: true
        opacity: 1
        title: ()->
          Handlebars.compile(
            $( $(this).data('tooltip-template') ).html()
          )({})
      },
      {
        position: 'centerTop'
        horizontalOffset: -10
        verticalOffset: -10
      }
    )


    # at the top of a document the document details box overlaps the
    # docuement content area. we want to force the content at the top
    # of the document to wrap early where this overlap is happening
    $('.doc-content-area .content-wrap-enforcement').css(
      'height',
       $('.doc-aside.doc-details').height() + 'px'
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
