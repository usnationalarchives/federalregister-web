class @FR2.TableFixedHeaderManager
  constructor: ()->
    @addEvents()

  addEvents: ->
    $('#documents').on('mouseenter', '.table-wrapper table', ->
      $(this).closest('.table-wrapper')
        .find('.expand-table-link .svg-tooltip')
        .addClass('hover')
        .trigger('mouseenter')
    )

    $('#documents').on('mouseleave', '.table-wrapper table', ->
      $(this).closest('.table-wrapper')
        .find('.expand-table-link .svg-tooltip')
        .removeClass('hover')
        .trigger('mouseleave')
    )

  perform: ->
    context         = this
    isSafari        = /Safari/.test(navigator.userAgent) && /Apple Computer/.test(navigator.vendor)
    backgroundColor = $('#fulltext_content_area').closest('.fr-box').css('background-color')

    expandTableLink = $(@expandTableMarkup())

    $('#documents .table-wrapper table').each (i) ->
      $(this).closest('.table-wrapper').prepend(expandTableLink.clone())

      docContentWidth = $(".doc-content-area").outerWidth()

      # Wide table handling
      if $(this).find('thead').width() > docContentWidth
        # Turn off fixed headers
        $(this).closest('.table-wrapper').css('overflow-x', 'hidden')
        # Apply gradient to table
        $(this).css('-webkit-mask-image', 'linear-gradient(to right, black 70%, transparent 100%)')
      else
        handler = new FR2.TableFixedHeaderHandler this, isSafari, backgroundColor
        handler.perform()
        $(this).html(handler.table.html())

    # Activate Semantic UI sticky
    _.each $('.expand-table-link'), (link)->
      stickyContainer = $(link).closest('.table-wrapper')
      $(link).sticky({
        context: $(stickyContainer),
        offset: 80
      })

    # Attach event listeners for deploying modals
    $('.expand-table-link').on 'click', (e)->
      new FR2.TableModalHandler(this)

  expandTableMarkup: ->
    '
    <div class="expand-table-positioning-wrapper hidden-print">
      <span class="expand-table-link ui sticky">
        <span class="svg-tooltip"
          data-toggle="tooltip"
          data-title="Click icon to view full table width">
          <svg class="svg-icon svg-icon-fullscreen">
            <use xlink:href="/assets/fr-icons.svg#fullscreen"></use>
          </svg>
        </span>
      </span>
    </div>
    '
