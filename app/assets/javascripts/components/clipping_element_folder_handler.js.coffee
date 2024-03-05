class @FR2.ClippingElementFolderHandler
  constructor: (folderEl, documentNumber)->
    @folderEl = $(folderEl)
    @documentNumber = documentNumber

    @addMouseEvents()

  addMouseEvents: ->
    @addMouseEnterEvents()
    @addMouseLeaveEvents()

  removeEvents: ->
    @folderEl.off('mouseenter')
    @folderEl.off('mouseleave')

  addMouseEnterEvents: ->
    @folderEl.on 'mouseenter', (e)=>
      @folderEl.addClass('hover')

      @removeInFolderIcon()
      @addGotoFolderButton()
      @addDeleteClippingButton()


  addMouseLeaveEvents: ->
    @folderEl.on 'mouseleave', (e)=>
      @folderEl.removeClass('hover')

      @removeGotoFolderButton()
      @removeDeleteClippingButton()
      @addInFolderIcon()

  addInFolderIcon: ->
    if @folderEl.find('a span.checked.icon').length == 0
      inFolderIcon = $('<span>')
        .addClass('checked icon icon-fr2 icon-fr2-badge_check_mark')

      @folderEl.find('a').append inFolderIcon

  removeInFolderIcon: ->
    @folderEl.find('a span.checked.icon').remove()

  addGotoFolderButton: ->
    gotoButton = $('<span>')
      .addClass('goto icon icon-fr2 icon-fr2-badge_forward_arrow')

    @folderEl.find('a').append gotoButton

    gotoButton.on 'click', (e)=>
      e.preventDefault()
      e.stopPropagation()

      folder = @folderEl.data('slug')
      window.location.href = '/my/folders/' + folder

  removeGotoFolderButton: ->
    @folderEl.find('a span.goto.icon').remove()

  addDeleteClippingButton: ->
    removeClippingButton = $('<span>')
      .addClass('delete icon icon-fr2 icon-fr2-badge_x')

    @folderEl.find('a').append removeClippingButton

    removeClippingButton.on 'click', (e)=>
      e.preventDefault()
      e.stopPropagation()

      @removeClippingFromFolder()

  removeDeleteClippingButton: ->
    @folderEl.find('a span.delete.icon').remove()

  removeClippingFromFolder: ->
    # hide icons and show loader
    @folderEl.find('a span.icon').hide()
    @folderEl.find('a span.loader').show()

    FR2.Analytics.trackClippingEvent 'remove', @document_number, @folderEl.data('slug')

    data = {
      folder_clippings: {
        folder_slug: @folderEl.data('slug'),
        document_number: @documentNumber
      }
    }

    clippingDelete = $.ajax({
      url: '/my/folder_clippings/delete',
      data: data,
      type: "POST"
    })

    clippingDelete.done (response)=>
      @folderEl.removeClass('in-folder').addClass('not-in-folder')

      @folderEl.find('a span.icon').remove()
      @folderEl.find('a span.loader').hide()

      @addInFolderIcon()

      @updateUserUtilCounts(response)

      @removeEvents()
      @folderEl.trigger('removeHandler', @folderEl.data('slug'))

  updateUserUtilCounts: (response)=>
    if @folderEl.data('slug') != 'my-clippings'
      # decrement the docs in folders count
      counts = $('#user_utils #document-count-holder #user_documents_in_folders_count')
      counts.html( parseInt(counts.html(), 0) - response.folder.doc_count )
    else
      counts = $('#user_utils #document-count-holder #doc_count')
      counts.html( parseInt(counts.html(), 0) - response.folder.doc_count )
