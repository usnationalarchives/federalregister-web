class @FR2.DocumentTableOfContents
  constructor: (tocEl)->
    @tocEl = $(tocEl)

    @addHoverBehavior()
    @addClickBehavior()

  addClickBehavior: ->
    @tocEl.on 'click', (e)->
      e.preventDefault()

      tocEl = $(this)
      tocMenu = tocEl.find('.dropdown-menu')
      docNav = $('.doc-nav-wrapper .doc-nav')

      tableOfContents = tocMenu.find('ul.table-of-contents')

      if tocMenu.hasClass?('open-lock')
        # unlock the toc
        tocEl.removeClass('open-lock')
        tocMenu.removeClass('open-lock')
        docNav.removeClass('toc-open-lock')
        tableOfContents.removeClass('interacting')

        # add a transition class to gently scroll the utility nav
        # into position, and then remove it so that the tranision
        # does not interfere with normal sticky nav operation
        docNav.addClass('toc-open-lock-removed-transition')
        setTimeout(
          ()->
            docNav.removeClass('toc-open-lock-removed-transition')
          510
        )
      else
        # lock the toc menu open
        tocEl.addClass('open-lock')
        tocMenu.addClass('open-lock')
        docNav.addClass('toc-open-lock')

        # mark the toc as being interacted with so that we can
        # set the max-height appropriately
        tableOfContents.addClass('interacting')


    @tocEl.on 'click', 'a', (e)->
      e.preventDefault()
      e.stopPropagation()

      linkEl = $(this)
      target = $(linkEl.attr('href'))
      docNav = linkEl.closest('.doc-nav')

      tableOfContents = docNav.find('ul.table-of-contents')

      if docNav.hasClass('toc-open-lock')
        scrollOffset = -230
        tableOfContents.removeClass('interacting')
      else
        scrollOffset = 0

      $('body').stop().animate({
        scrollTop: target.offset().top + scrollOffset
      }, 300)

  addHoverBehavior: ->
    @tocEl.on 'mouseenter', 'ul.table-of-contents', (e)->
      $(this).addClass('interacting')

    @tocEl.on 'mouseleave', 'ul.table-of-contents', (e)->
      $(this).removeClass('interacting')
