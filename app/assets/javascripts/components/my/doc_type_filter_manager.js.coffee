class @FR2.DocTypeFilterManager
  constructor: ->
    @addFilterEvents()

  addFilterEvents: ->
    manager = this
    $('#doc-type-filter li').each( ->
      if ( manager.docTypeFilters().includes( $(this).data('filter-doc-type') ) )
        $(this).addClass('on')
        $(this).data('tooltip',
          'Hide documents of type ' + $(this).data('filter-doc-type-display')
        )
      else
        $(this).addClass('disabled')
        $(this).data('tooltip',
          'No documents of type ' + $(this).data('filter-doc-type-display') + ' have been clipped'
        )
    )

    $('#doc-type-filter li:not(.disabled)').bind('mouseenter', ->
      $(this).addClass('hover')
    )

    $('#doc-type-filter li:not(.disabled)').bind('mouseleave', ->
      $(this).removeClass('hover')
    )

    $('#doc-type-filter li:not(.disabled)').bind('click', ->
      manager.filterClippingsByType( $(this) )
    )

  filterClippingsByType: (el)->
    doc_type = el.data('filter-doc-type')
    doc_type_filters = @docTypeFilters()

    if ( el.hasClass('on') )
      el.removeClass('on')
      el.removeClass('hover')

      el.data('tooltip',
        'Show documents of type ' + el.data('filter-doc-type-display')
      )
      el.tipsy('hide')
      el.tipsy('show')

      index = _.indexOf(doc_type_filters, doc_type)
      doc_type_filters[index] = null
      doc_type_filters = _.compact(doc_type_filters)
    else
      el.addClass('on')

      el.data('tooltip',
        'Hide documents of type ' + el.data('filter-doc-type-display')
      )
      el.tipsy('hide')
      el.tipsy('show')

      doc_type_filters.push( doc_type )

    documents_to_hide = $('ul#clippings li').toArray().filter((clipping) ->
      ! doc_type_filters.includes( $(clipping).data('doc-type') )
    )

    $('#clippings li').show()
    $(documents_to_hide).hide()

  currentFolder: ->
    currentFolderSlug = $("#main h2.title").data().folderSlug

    @userFolderDetails().folders.find((folder) ->
      folder.slug == currentFolderSlug
    )

  docTypeFilters: ->
    @currentFolder().document_types

  userFolderDetails: ->
    folderDetails = FR2.currentUserStorage.get('userFolderDetails')

    if folderDetails == undefined
      JSON.parse('{"folders": []}')
    else
      folderDetails
