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

    new FR2.DocumentTableOfContents('ul.doc-nav > li.doc-toc')

    $('ul.doc-nav > li').click (e)->
      # this shouldn't be neccessary but is for some reason...
      if e.toElement.tagName != 'A'
        e.preventDefault()

      e.stopPropagation()

    if $('.doc-nav-wrapper').length > 0
      $('.doc-document ul.doc-nav').sticky({
        context: '.doc-content.with-utility-bar'
      })

      # set the height of the nav wrapper after we've loaded web fonts
      # otherwise the height won't be correct
      $('body').on 'typekit-active', ->
        $('.doc-document ul.doc-nav').sticky('refresh')

        # ideally we don't want a timeout here but semantic-ui sticky
        # makes the wrapper bigger than it should be - so we wait for it
        # to finish before fixing.
        setTimeout(
          ->
            frBox = $('.doc-nav-wrapper').siblings('.fr-box').first()
            $('.doc-nav-wrapper').outerHeight(frBox.height() + 'px')
          1000
        )
