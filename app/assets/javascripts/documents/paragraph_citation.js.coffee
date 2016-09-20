$(document).ready ()->
  $('body').on 'typekit-active', ->
    hash = window.location.hash

    if hash != "" && $(hash).length
      $('html, body').stop().animate({
        scrollTop: $(hash).offset().top - 20
      }, 500)
