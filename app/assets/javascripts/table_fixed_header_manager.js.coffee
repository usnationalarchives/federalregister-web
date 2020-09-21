class @FR2.TableFixedHeaderManager
  constructor: (tooltipOptions)->
    @tooltipOptions = tooltipOptions

  perform: ->
    context         = this
    isSafari        = /Safari/.test(navigator.userAgent) && /Apple Computer/.test(navigator.vendor)
    backgroundColor = $('#fulltext_content_area').closest('.fr-box').css('background-color')

    $('#documents .table-wrapper table').each (i) ->
      expandTableLink = Handlebars.compile $("#expand-table-link-template").html()

      $(this).closest('.table-wrapper').prepend(expandTableLink)

      # Wide table handling
      if $(this).data('point-width') > 300
        # Turn off fixed headers
        $(this).closest('.table-wrapper').css('overflow-x', 'hidden')
        # Apply gradient to table
        $(this).css('-webkit-mask-image', 'linear-gradient(to right, black 70%, transparent 100%)')
        # Change tooltip
        $(this).closest('.table-wrapper').find('.expand-table-link').attr('data-tooltip', 'Click to access full width of table')
      else
        handler = new FR2.TableFixedHeaderHandler this, isSafari, backgroundColor
        handler.perform()
        $(this).html(handler.table.html())

    # Activate tooltips added to DOM after page load
    CJ.Tooltip.addTooltip(
      '.expand-table-link.bootstrap-tooltip',
      context.tooltipOptions
    )

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
