$(document).ready ()->
  $('body').on 'typekit-active', ->
    hash = window.location.hash

    if hash != "" && $(hash).length
      $('html, body').stop().animate({
        scrollTop: $(hash).offset().top - 20
      }, 500)

  if $('#fulltext_content_area').length
    new FR2.ParagraphCitation $('#fulltext_content_area')
