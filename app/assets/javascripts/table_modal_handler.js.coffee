class @FR2.TableModalHandler
  constructor: (expandTableLink)->
    @expandTableLink = expandTableLink
    @tableFixedHeaderHandler = FR2.TableFixedHeaderHandler
    this.displayModal()
    this._centerTableInModal()
    this._applyCustomModalDisplayBehavior()
    this.adjustThCss()

  displayModal: ->
    clonedTable = $(this.expandTableLink).closest('.table-wrapper').find('table').clone(true).off()
    #Remove gradient
    clonedTable.css('-webkit-mask-image', '')
    if clonedTable.find('caption').length == 0
      clonedTable.css('margin-top', '25px')

    modalHtml = "<div class='modal-document-table-wrapper'><div class='fr-box-official'><div class='content-block doc-content-area no-overflow'>#{clonedTable.get(0).outerHTML}</div></div>"

    this.invokeModal(modalHtml)
    this._centerTableInModal()

  invokeModal: (modalHtml) ->
    # Find empty modal rendered to page
    modal = $('.document-table-modal').first()

    # Remove FR Box footer since it interferes with horizontal scrolling
    modal.find('.fr-seal-block-footer').remove()

    # Add dynamic content to modal (Ideally this would be handlebars-based at some point)
    modal.find('.content-block').empty()
    modal.find('.content-block').html(modalHtml)
    modal.modal('show')
    this._resetModalScrollbarPosition()

  adjustThCss: ->
    handler = new this.tableFixedHeaderHandler($('.modal-body table'), this._isSafari())
    handler.perform()
    $('.modal-body table').html(handler.table.html())

  _applyCustomModalDisplayBehavior: ->
    # Move modal into main div (it's not visible otherwise)
    $('.modal-backdrop').appendTo( $('.bootstrap-scope').last() )
    # Disable page scrolling
    $('body').css('overflow', 'hidden')

    $('#bootstrap-table-modal').on('hidden.bs.modal', ->
      # Manually remove modal backdrop on close
      $('.modal-backdrop').first().remove()
      # Re-enable page scrolling
      $('body').css('overflow-x', 'hidden')
      $('body').css('overflow-y', 'auto')
    )

  _isSafari: ->
    /Safari/.test(navigator.userAgent) && /Apple Computer/.test(navigator.vendor)

  # The modal retains its scroll position on exit
  _resetModalScrollbarPosition: ->
    $('.modal-body .content-block').first().scrollTop(0)

  _centerTableInModal: ->
    modalTable = $('.modal-body').find('table')
    tableWidth = $('.modal-body').find('table thead').width()
    modalTable.css('width', tableWidth)
    modalTable.css('margin', '25px auto 0')

