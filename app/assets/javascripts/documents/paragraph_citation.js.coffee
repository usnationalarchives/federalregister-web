$(document).ready ()->
  if $('#fulltext_content_area').length

    if window.location.hash
      paragraphTarget = $(window.location.hash)

      # ensure we scroll to the correct paragraph after webfont load
      $('body').on 'typekit-active', ->
        $('html, body').stop().animate({
          scrollTop: paragraphTarget.offset().top - 20
        }, 500)

    # enable paragraph citations
    new FR2.ParagraphCitation $('#fulltext_content_area')
