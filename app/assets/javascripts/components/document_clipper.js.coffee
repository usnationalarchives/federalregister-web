class @FR2.DocumentClipper
  clipperTemplate: ->
    HandlebarsTemplates.add_to_folder_menu_fr2

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

  storedDocumentNumbers: ->
    storedDocumentNumbers = FR2.currentUserStorage.get('storedDocumentNumbers')

    if storedDocumentNumbers == undefined
      []
    else
      storedDocumentNumbers

  folderDetails: ->
    folderDetails = FR2.currentUserStorage.get('userFolderDetails')

    if folderDetails == undefined
      JSON.parse('{"folders": []}')
    else
      folderDetails

  addClipper: ->
    attachTo = @clipper.find 'li.clip-for-later'

    #create a shallow copy for this instance of DocumentClipper
    folderDetails = _.clone @folderDetails()

    data = Object.assign(
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

    @folderDetails().folders.filter((folder)->
      folder.documents.includes( documentClipper.documentNumber )
    ).length != 0

  documentInClipboard: ->
    clipboard = _.find @folderDetails().folders, (folder)->
      folder.slug == 'my-clippings'

    clipboard.documents.includes( @documentNumber )

  addDocumentToFolder: (menuItem)->
    if FR2.UserUtils.loggedIn()
      documentClipper = this

      menuItem.find('.icon.checked').hide()
      menuItem.find('.loader').show()

      FR2.Analytics.trackClippingEvent('add', @documentNumber, menuItem.data('slug'))

      data = [
        {
          name: "document[document_number]",
          value: @documentNumber
        },
        {
          name: "document[folder]",
          value: menuItem.data('slug')
        },
        {
          name: 'ajax_request',
          value: true
        }
      ]

      clip = $.ajax({
        url: '/my/clippings',
        data: data,
        type: "POST"
      })

      clip.done (response) ->
        menuItem.removeClass('not-in-folder').addClass('in-folder')

        documentClipper.updateClippedStatus()

        documentClipper.addFolderElementHandler(menuItem)

      clip.always (response)->
        menuItem.find('.loader').hide()
        menuItem.find('.icon.checked').show()
    else
      @displayAccountNeededModal()


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
    modalTemplate = HandlebarsTemplates['new_folder_modal']

    FR2.Modal.displayModal("", modalTemplate(), {includeTitle: false, modalClass: 'new-folder-modal'})

    $('body').on 'folderCreated', '#fr_modal', @runFolderCreationHandler

    @folderHandler = new FR2.ClippingsFolderHandler(
      $('#fr_modal.new-folder-modal'),
      @documentNumber
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
    template = HandlebarsTemplates['add_to_folder_menu_li_fr2']

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
