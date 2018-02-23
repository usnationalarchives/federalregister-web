class @FR2.ClippingsManager
  constructor: (actionBar)->
    @actionBar = $(actionBar)

    @addMenus()
    @addEvents()

  addMenus: ->
    @addViewFolderMenu()
    @addAddToFolderMenu()

  addViewFolderMenu: ->
    template = Handlebars.compile $("#jump-to-folder-menu-template").html()
    @actionBar.append template(user_folder_details)

  addAddToFolderMenu: ->
    template = Handlebars.compile $("#add-to-folder-menu-template").html()
    @actionBar.append template(user_folder_details)

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

    @actionBar.on 'click', '.remove-clipping', (event)->
      event.preventDefault()
      clippingManager.deleteClippings()

  showMenu: (el)->
    $(el).addClass 'hover'

  hideMenu: (el)->
    $(el).removeClass 'hover'

  clippingIds: ->
    _.map $('form#folder_clippings input:checked'), (input)->
      return $(input).closest('li').data('doc-id')

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

    deleteClippings.success (response)->
      _.each response.folder.documents, (doc_id)->
        $("#clippings li[data-doc-id='" + doc_id + "']")
          .animate({opacity: 0}, 600)

      setTimeout(
        ()->
          _.each response.folder.documents, (doc_id)->
            $("#clippings li[data-doc-id='" + doc_id + "']").remove()

          update_clippings_on_page_count response.folder.doc_count
          update_add_folder_count response, 'remove'
          update_jump_folder_count response, 'remove'
          update_user_util_counts response.folder.doc_count, response.folder.slug, false, 'delete'
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

      moveClippings.success (response)=>
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
            update_jump_folder_count response
            update_user_util_counts response.folder.doc_count, response.folder.slug, false
          2400
        )


  displayNewFolderModal: ->
    modalTemplate = Handlebars.compile $("#new-folder-modal-template").html()

    FR2.Modal.displayModal("", modalTemplate(), {includeTitle: false, modalClass: 'new-folder-modal'})

    $('body').on 'folderCreated', '#fr_modal', @runFolderCreationHandler

    @folderHandler = new FR2.ClippingsFolderHandler(
      $('#fr_modal.new-folder-modal'),
      @clippingIds()
    )

  displayAccountNeededModal: ->
    modalTemplate = Handlebars.compile $("#account-needed-modal-template").html()

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
        update_user_util_counts response.folder.doc_count, response.folder.slug, true
      2400
    )


  addNewFolderToMenus: (response)->
    template = Handlebars.compile $("#add-to-folder-menu-li-template").html()

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
    _.each response.folder.documents, (doc_id)->
      $("#clippings li[data-doc-id='#{doc_id}']")
        .animate(
          {opacity: 0},
          {
            duration: 600,
            done: ->
              this.remove()
          }
        )

    update_clippings_on_page_count response.folder.doc_count
    update_current_folder_page_counts response.folder.doc_count
