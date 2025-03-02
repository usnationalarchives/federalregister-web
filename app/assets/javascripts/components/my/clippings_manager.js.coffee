class @FR2.ClippingsManager
  constructor: (actionBar)->
    @actionBar = $(actionBar)

    @addMenus()
    @addEvents()
    # Initialize select all checkbox state
    $('#clipping-actions #select-all-clippings').
      tipsy( {gravity: 's', fade: true, offset: 2})
    @_refreshSelectAllTooltip(false)

  addMenus: ->
    @addViewFolderMenu()
    @addAddToFolderMenu()

  addViewFolderMenu: ->
    template = HandlebarsTemplates['jump_to_folder_menu']
    @actionBar.append template(@userFolderDetails())

  addAddToFolderMenu: ->
    template = HandlebarsTemplates['add_to_folder_menu']
    @actionBar.append template(@userFolderDetails())

  userFolderDetails: ->
    folderDetails = FR2.currentUserStorage.get('userFolderDetails')

    if folderDetails == undefined
      JSON.parse('{"folders": []}')
    else
      folderDetails

  addEvents: ->
    clippingManager = this

    # enable new folder creation
    @actionBar.on 'click', '.add-to-folder #new-folder', (event)->
      event.preventDefault()
      clippingManager.handleNewFolderAction()

    # enable moving items to existing folder
    @actionBar.on 'click', '.add-to-folder li:not(#new-folder)', (event)->
      event.preventDefault()
      clippingManager.moveItemsToFolder(this)

    # bound individually
    @actionBar.on 'mouseenter', '.add-to-folder', ()->
      clippingManager.showMenu this

    @actionBar.on 'mouseleave', '.add-to-folder', ()->
      clippingManager.hideMenu this

    @actionBar.on 'mouseenter', '.jump-to-folder', ()->
      clippingManager.showMenu this

    @actionBar.on 'mouseleave', '.jump-to-folder', ()->
      clippingManager.hideMenu this

    @actionBar.on 'click', '#select-all-clippings', (event)->
      event.preventDefault()
      checkboxes = $('#clippings .clipping_id')

      if clippingManager._allClippingsChecked()
        checkboxes.each ()->
          $(this).prop('checked', false)
      else
        checkboxes.each ()->
          $(this).prop('checked', true)
      clippingManager._refreshSelectAllTooltip(true)

    # update select all tooltip when a clipping is selected
    $('#clippings').on 'click', 'input.clipping_id', (event)->
      clippingManager._refreshSelectAllTooltip(false)

    @actionBar.on 'click', '.remove-clipping', (event)->
      event.preventDefault()
      clippingManager.deleteClippings()

  _refreshSelectAllTooltip: (changeOnScreenTooltip) ->
    selectAllCheckbox = $('#clipping-actions #select-all-clippings')
    if this._allClippingsChecked()
      message = 'Deselect all clippings'
    else
      message = 'Select all clippings'

    selectAllCheckbox.prop('title', message)
    if changeOnScreenTooltip
      $('.tipsy .tipsy-inner').text(message)

  _allClippingsChecked: ->
    allChecked = true
    checkboxes = $('#clippings .clipping_id')
    checkboxes.each ->
      unless $(this).prop('checked')
        allChecked   = false
    allChecked

  showMenu: (el)->
    $(el).addClass 'hover'

  hideMenu: (el)->
    $(el).removeClass 'hover'

  clippingIds: ->
    $('form#folder_clippings input:checked').toArray().map((input)->
      return $(input).closest('li').data('doc-id')
    )

  deleteClippings: ->
    unless @clippingIds()
      return false

    currentFolderSlug = $('h2.title').data('folder-slug')

    form = $('form#folder_clippings')
    formData = form.serializeArray()

    formData.push {
      name: "folder_clippings[clipping_ids]",
      value: @clippingIds()
    }

    formData.push {
      name: "folder_clippings[folder_slug]",
      value: currentFolderSlug
    }

    deleteClippings = $.ajax({
      url: '/my/folder_clippings/delete',
      data: formData,
      type: "POST"
    })

    deleteClippings.done (response)->
      response.folder.documents.forEach((doc_id)->
        $("#clippings li[data-doc-id='" + doc_id + "']")
          .animate({opacity: 0}, 600)
      )

      setTimeout(
        ()->
          response.folder.documents.forEach((doc_id)->
            $("#clippings li[data-doc-id='" + doc_id + "']").remove()
          )

          @update_clippings_on_page_count response.folder.doc_count
          @update_add_folder_count response, 'remove'
          @update_jump_folder_count response, 'remove'
        600
      )

  handleNewFolderAction: ->
    @actionBar.off 'mouseleave', '.add-to-folder'
    @actionBar.find('.add-to-folder .menu li#new-folder')
      .addClass('hover')

    if FR2.UserUtils.loggedIn()
      @displayNewFolderModal()
    else
      @displayAccountNeededModal()

  moveItemsToFolder: (el)->
    checkedItems = $('form#folder_clippings input:checked')
    currentFolderSlug = $('h2.title').data('folder-slug')
    moveToFolderSlug = $(el).data('slug')

    if checkedItems.length > 0 && moveToFolderSlug != currentFolderSlug
      link = $(el).find('a')
      documentCount = link.find('.document_count')
      loader = link.find('.loader')

      documentCount.css('opacity', 0)
      loader.show()

      form = $('form#folder_clippings')
      formData = form.serializeArray()

      formData.push {
        name: "folder_clippings[clipping_ids]",
        value: @clippingIds()
      }

      formData.push {
        name: "folder_clippings[folder_slug]",
        value: moveToFolderSlug
      }

      moveClippings = $.ajax({
        url: '/my/folder_clippings',
        data: formData,
        type: "POST"
      })

      moveClippings.done (response)=>
        loader.hide()

        documentCountText = documentCount.find('.document_count_inner')
        documentCountText.html(
          parseInt(documentCountText.html(), 0) +
            parseInt(response.folder.doc_count, 0)
        )

        updateCount = $('<span>')
          .addClass('update')
          .html("+#{response.folder.doc_count}")
          .css('opacity', 1)

        link.append updateCount

        # the following are run in a sequence using coordinated timeouts
        updateCount.animate(
          {opacity: 0},
          {
            duration: 1200,
            done: =>
              @crossFadeUpdateAndDocumentCounts(updateCount, documentCount)
          }
        )

        setTimeout(
          =>
            @removeMovedItemsFromView response
            @update_jump_folder_count response
          2400
        )


  displayNewFolderModal: ->
    modalTemplate = HandlebarsTemplates['new_folder_modal']

    FR2.Modal.displayModal("", modalTemplate(), {includeTitle: false, modalClass: 'new-folder-modal'})

    $('body').on 'folderCreated', '#fr_modal', @runFolderCreationHandler

    @folderHandler = new FR2.ClippingsFolderHandler(
      $('#fr_modal.new-folder-modal'),
      @clippingIds()
    )

  displayAccountNeededModal: ->
    modalTemplate = HandlebarsTemplates['account_needed_modal']

    url_params = {redirect_to: window.location.href}
    redirectUrl = "/auth/sign_in?#{$.param(url_params)}"

    FR2.Modal.displayModal("", modalTemplate({redirectUrl: redirectUrl}), {includeTitle: false})
    @addModalClosedHandler()

  addModalClosedHandler: ->
    $('body').on 'modalClose', '#fr_modal', @rebindAndCloseClippingMenu

  rebindAndCloseClippingMenu: =>
    # remove handlers
    #@folderHandler = null
    $('body').off 'modalClose', '#fr_modal', @rebindAndCloseClippingMenu

    clippingManager = this

    # rebind the hover behavior
    @actionBar.on 'mouseleave', '.add-to-folder', ()->
      clippingManager.hideMenu this

    # close the menu
    clippingManager.hideMenu @actionBar.find('.add-to-folder')

    # remove hover classes
    @actionBar.find('.add-to-folder .menu li#new-folder')
      .removeClass('hover')

  runFolderCreationHandler: (e, response)=>
    update_user_folder_and_document_count response

    # remove handler
    $('body').off 'folderCreated', '#fr_modal', @runFolderCreationHandler

    # the following are run in a sequence using coordinated timeouts
    @addNewFolderToMenus response

    setTimeout(
      =>
        @removeMovedItemsFromView response
      2400
    )


  addNewFolderToMenus: (response)->
    template = HandlebarsTemplates['add_to_folder_menu_li']

    newFolderEl = $(template(response))
    newGotoFolderEl = newFolderEl.clone()

    # add the new folder to the goto menu
    newGotoFolderEl
      .find('a')
      .attr('href', "/my/folders/#{response.folder.slug}")

    @actionBar.find('.jump-to-folder .menu ul').append(
      newGotoFolderEl
    )

    # add the new folder to the move-to menu
    @actionBar.find('.add-to-folder .menu ul').append(
      newFolderEl
        .css('opacity', 0)
    )

    # create our elements to show where items were moved to
    link = newFolderEl.find('a')
    documentCount = link.find('.document_count')

    updateCount = $('<span>')
      .addClass('update')
      .html("+#{response.folder.doc_count}")
      .css('opacity', 1)

    # add in update count and hide final folder document count
    documentCount.css('opacity', 0)
    link.append updateCount

    # fade in the new folder element
    newFolderEl.animate(
      {opacity: 1.0},
      {
        duration: 1200,
        done: =>
          @crossFadeUpdateAndDocumentCounts(updateCount, documentCount)
      }
    )

  # after move of items or creation of a folder with items
  # cross fade the update count and final folder document count
  crossFadeUpdateAndDocumentCounts: (updateCount, documentCount)=>
    updateCount.animate(
      {opacity: 0},
      600
    )

    documentCount.animate(
      {opacity: 1},
      {
        duration: 1200,
        done: =>
          @rebindAndCloseClippingMenu()
      }
    )


  removeMovedItemsFromView: (response)->
    response.folder.documents.forEach((doc_id)->
      $("#clippings li[data-doc-id='#{doc_id}']")
        .animate(
          {opacity: 0},
          {
            duration: 600,
            done: ->
              this.remove()
          }
        )
    )

    @update_clippings_on_page_count response.folder.doc_count
    @update_current_folder_page_counts response.folder.doc_count

  update_clippings_on_page_count: (count) ->
    count_span = $('#folder_metadata_bar span.clippings_on_page_count')
    current_count = parseInt( count_span.html(), 0 )
    count_span.html( current_count - count)

  update_current_folder_page_counts: (count) ->
    current_folder_slug = $('h2.title').data('folder-slug')
    jump_to_folder_inner = $('#jump-to-folder .menu li[data-slug="' + current_folder_slug + '"] .document_count_inner')
    add_to_folder_inner  = $('#add-to-folder .menu li[data-slug="' + current_folder_slug + '"] .document_count_inner')

    jump_to_folder_inner.html( parseInt(jump_to_folder_inner.html(), 0) - count )
    add_to_folder_inner.html( parseInt(add_to_folder_inner.html(), 0) - count )

  update_add_folder_count: (response, action) ->
    add_to_folder_inner = $('#add-to-folder .menu li[data-slug="' + response.folder.slug + '"] .document_count_inner')

    if (action == undefined || action == 'add')
      add_to_folder_inner.html( parseInt(add_to_folder_inner.html(), 0) + response.folder.doc_count )
    else if (action == 'remove')
      add_to_folder_inner.html( parseInt(add_to_folder_inner.html(), 0) - response.folder.doc_count )

  update_jump_folder_count: (response, action) ->
    jump_to_folder_inner = $('#jump-to-folder .menu li[data-slug="' + response.folder.slug + '"] .document_count_inner')

    if (action == undefined || action == 'add')
      jump_to_folder_inner.html( parseInt(jump_to_folder_inner.html(), 0) + response.folder.doc_count )
    else if (action == 'remove')
      jump_to_folder_inner.html( parseInt(jump_to_folder_inner.html(), 0) - response.folder.doc_count )
