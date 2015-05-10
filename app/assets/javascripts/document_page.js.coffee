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
    $('.stars.cj-fancy-tooltip'),
    {
      className: 'stars-tooltip'
      gravity: 's'
      opacity: 0.9
      delay: 0.3
      fade: true
    },
    {
      position: 'centerTop'
      horizontalOffset: -10
      verticalOffset: -10
    }
  )
