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


    $('.doc-content-area .content-wrap-enforcement').css(
      'height',
       $('.doc-aside.doc-details').height() + 'px'
    )
