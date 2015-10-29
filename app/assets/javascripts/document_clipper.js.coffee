class @FR2.DocumentClipper
  clipperTemplate: ->
    Handlebars
      .compile $("#add-to-folder-menu-fr2-template").html()

  constructor: (clipper)->
    @clipper = $(clipper)
    @documentNumber = @clipper.data 'document-number'

    @hideAndDisableForm()
    @addClipper()
    @addClipperEvents()

  hideAndDisableForm: ->
    @clipper.find('form.add-to-clipboard')
      .hide()
      .bind 'submit', (event)->
        event.preventDefault()

  addClipper: ->
    attachTo = @clipper.find 'li.clip-for-later'
    attachTo.append(
      $('<div>')
        .addClass("clipping-actions fr2")
        .append(
          @clipperTemplate(
            _.extend(
              user_folder_details, {current_document_number: @documentNumber}
            )
          )
        )
    )

  addClipperEvents: ->
    documentClipper = this

    # show clipping menu
    @clipper.on 'mouseenter', '.add-to-folder, #jump-to-folder', ()->
      documentClipper.showClippingMenu this

    # hide clipping menus
    # need to be delegated seperately so that we can unbind them individually
    @clipper.on 'mouseleave', '.add-to-folder', ()->
      documentClipper.hideClippingMenu this

    @clipper.on 'mouseleave', '#jump-to-folder', ()->
      documentClipper.hideClippingMenu this

  showClippingMenu: (el)->
    # turn on hover
    # this needs to be in js or we get weird interactions between js triggered
    # hovers and css hover states - no one wants a flickering menu
    $(el).addClass 'hover'

  hideClippingMenu: (el)->
    $(el).removeClass 'hover'
