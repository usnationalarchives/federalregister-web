$(document).ready ()->
  if $('ul.doc-nav')
    $('ul.doc-nav > li').hover(
      ->
        el = $(this)
        el.find('.dropdown-menu').stop(true, true).show()
        el.addClass('open')
      ->
        el = $(this)
        el.find('.dropdown-menu').stop(true, true).hide()
        el.removeClass('open')
    )

    $('ul.doc-nav > li').click (e)->
      # this shouldn't be neccessary but is for some reason...
      if e.toElement.tagName != 'A'
        e.preventDefault()

      if !$(e.target).hasClass('force-event-propagation')
        e.stopPropagation()

    if $('.doc-nav-wrapper').length > 0
      $('.doc-document ul.doc-nav').sticky({
        context: '.doc-content.with-utility-bar'
      })
