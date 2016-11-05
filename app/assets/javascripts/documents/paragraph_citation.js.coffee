$(document).ready ()->
  if $('#fulltext_content_area').length

    if window.location.hash && window.location.hash != "#open-comment" && window.location.hash != "#addresses"
      paragraphTarget = $(window.location.hash)

      # ensure we scroll to the correct paragraph after webfont load
      $('body').on 'typekit-active', ->
        $('html, body').stop().animate({
          scrollTop: paragraphTarget.offset().top - 20
        }, 500)

      # visually identify the cited paragraph
      linkIcon = $('<span>')
        .addClass('icon-fr2 icon-fr2-link')
        .data('tooltip', 'The url for this page contains a citation. This is the item that is cited.')
      paragraphTarget.append linkIcon
      CJ.Tooltip.addFancyTooltip linkIcon,
        { className: 'dynamic-citation-tooltip'},
        {
          horizontalOffset: -5
          position: 'centerTop'
          verticalOffset: -12
        }

    # enable paragraph citations
    new FR2.ParagraphCitation $('#fulltext_content_area')
