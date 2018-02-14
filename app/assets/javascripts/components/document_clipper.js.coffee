class @FR2.DocumentClipper
  clipperTemplate: ->
    Handlebars
      .compile $("#add-to-folder-menu-fr2-template").html()

  constructor: (clipper)->
    @clipper = $(clipper)
    @documentNumber = @clipper.data 'document-number'

    @folderElementHandlers = {}

    @hideAndDisableForm()
    @addClipper()
    @addClipperEvents()
    @addTooltip()

  hideAndDisableForm: ->
    @clipper.find('form.add-to-clipboard')
      .hide()
      .bind 'submit', (event)->
        event.preventDefault()

  folderDetails: ->
    FR2.currentUserStorage.get('userFolderDetails')

  addClipper: ->
    attachTo = @clipper.find 'li.clip-for-later'

    #create a shallow copy for this instance of DocumentClipper
    folderDetails = _.clone @folderDetails()

    data = _.extend(
      folderDetails,
      {
        currentDocumentNumber: @documentNumber,
        clipped: @documentClipped()
      }
    )

    attachTo.append(
      @clipperTemplate()(data)
    )

  addClipperEvents: ->
    @addMouseEvents()
    @addClickEvents()
    @addFolderElementHandlers()

  addMouseEvents: ->
    documentClipper = this

    # show clipping menu
    @clipper.on 'mouseenter', '.add-to-folder', ()->
      documentClipper.showClippingMenu this

    # hide clipping menu
    @clipper.on 'mouseleave', '.add-to-folder', ()->
      documentClipper.hideClippingMenu this

  addClickEvents: ->
    documentClipper = this
    menu = @clipper.find('.menu')

    # remove default click events
    menu.on 'click', 'li, li a', (event)->
      event.preventDefault()

    # allow icon to be clicked as a shortcut for adding current document to the clipboard
    @clipper.on 'click', '.button', (event)->
      if !documentClipper.documentInClipboard()
        menu
          .find 'li[data-slug="my-clippings"]'
          .trigger 'click'

    # enable saving to folder
    menu.on 'click', 'li.not-in-folder', (event)->
      documentClipper.addDocumentToFolder $(this)

    # enable new folder creation
    menu.on 'click', '#new-folder', (event)->
      documentClipper.handleNewFolderAction()

  addFolderElementHandlers: ->
    _.each @clipper.find('.menu li.in-folder'), (el)=>
      @addFolderElementHandler(el)

  showClippingMenu: (el)->
    # turn on hover
    # this needs to be in js or we get weird interactions between js triggered
    # hovers and css hover states - no one wants a flickering menu
    $(el).addClass 'hover'

  hideClippingMenu: (el)->
    $(el).removeClass 'hover'

  addTooltip: ->
    CJ.Tooltip.addTooltip(
      @clipper.find('.add-to-folder'),
      {
        offset: 2
      }
    )

  documentClipped: ->
    documentClipper = this

    _.filter(
      @folderDetails().folders, (folder)->
        _.contains(folder.documents, documentClipper.documentNumber)
    ).length != 0

  documentInClipboard: ->
    clipboard = _.find @folderDetails().folders, (folder)->
      folder.slug == 'my-clippings'

    _.contains clipboard.documents, @documentNumber

  addDocumentToFolder: (menuItem)->
    if FR2.UserUtils.loggedIn()
      documentClipper = this

      menuItem.find('.icon.checked').hide()
      menuItem.find('.loader').show()

      track_clipping_event('add', @documentNumber, menuItem.data('slug'))

      data = [
        {
          name: "document[document_number]",
          value: @documentNumber
        },
        {
          name: "document[folder]",
          value: menuItem.data('slug')
        }
      ]

      clip = $.ajax({
        url: '/my/clippings',
        data: data,
        type: "POST"
      })

      clip.success (response)->
        menuItem.removeClass('not-in-folder').addClass('in-folder')

        documentClipper.updateClippedStatus()

        documentClipper.addFolderElementHandler(menuItem)

        if menuItem.data('slug') == "my-clippings"
          update_user_clipped_document_count stored_document_numbers
        else
          update_user_folder_document_count response



      clip.complete (response)->
        menuItem.find('.loader').hide()
        menuItem.find('.icon.checked').show()
    else
      @displayAccountNeededModal(url)


  updateClippedStatus: =>
    if @clipper.find('.menu .in-folder').length > 0
      @clipper.find('.icon-fr2-flag').addClass('clipped')
    else
      @clipper.find('.icon-fr2-flag').removeClass('clipped')

  handleNewFolderAction: ->
    # disable the hover menu and keep open
    @clipper.unbind('mouseleave')
    @clipper.addClass('hover')
    @clipper.find('.menu li#new-folder').addClass('hover')

    if FR2.UserUtils.loggedIn()
      @displayNewFolderModal()
    else
      @displayAccountNeededModal()


  displayNewFolderModal: ->
    modalTemplate = Handlebars.compile $("#new-folder-modal-template").html()

    FR2.Modal.displayModal("", modalTemplate(), {includeTitle: false, modalClass: 'new-folder-modal'})

    $('body').on 'folderCreated', '#fr_modal', @runFolderCreationHandler

    @folderHandler = new FR2.ClippingsFolderHandler(
      $('#fr_modal.new-folder-modal'),
      @documentNumber
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
    @folderHandler = null
    $('body').off 'modalClose', '#fr_modal', @rebindAndCloseClippingMenu

    documentClipper = this

    # rebind the hover behavior
    @clipper.on 'mouseleave', '.add-to-folder', ()->
      documentClipper.hideClippingMenu this

    # close the menu
    documentClipper.hideClippingMenu @clipper.find('.add-to-folder')

  runFolderCreationHandler: (e, response)=>
    update_user_folder_and_document_count response
    @addNewFolderToMenus response

    #remove handler
    $('body').off 'folderCreated', '#fr_modal', @runFolderCreationHandler

  addNewFolderToMenus: (response)->
    template = Handlebars.compile $("#add-to-folder-menu-li-fr2-template").html()

    # add folder to current menu, add element actions, close menu
    newFolderEl = $(template(response))

    @clipper.find('.menu ul').append(
      newFolderEl
        .css('opacity', 0)
        .animate(
          {opacity: 1.0},
          {
            duration: 1500,
            done: =>
              @addFolderElementHandler(newFolderEl)
              @rebindAndCloseClippingMenu()
          }
        )
    )

    # mark as clipped
    @clipper.find('.icon-fr2-flag').addClass('clipped')

    # add folder to other menus on page (search results page)
    # but mark as not clipped
    _.each $('.document-clipping-actions'), (clipper)=>
      unless @clipper.is $(clipper)
        newFolderEl = $(template(response))

        $(clipper).find('.menu ul').append(newFolderEl)
        newFolderEl.removeClass('in-folder').addClass('not-in-folder')

  addFolderElementHandler: (el)->
    # create handler
    handler = new FR2.ClippingElementFolderHandler(el, @documentNumber)

    # store reference to handler
    @folderElementHandlers[$(el).data('slug')] = handler

    # listen for handler removal state and remove reference, which delets object
    $(el).on 'removeHandler', (e, slug)=>
      @folderElementHandlers[slug] = null
      @updateClippedStatus()
