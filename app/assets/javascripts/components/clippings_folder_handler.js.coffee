class @FR2.ClippingsFolderHandler
  constructor: (folderModal, documentNumber) ->
    @modal = folderModal

    # handle our two cases for creating a folder and adding documents
    # to it.
    if typeof(documentNumber) == 'string'
      @documentNumber = documentNumber
      @clippingIds = null
    else if typeof(documentNumber) == 'object'
      @documentNumber = null
      @clippingIds = documentNumber


    @form = @modal.find('form')

    @form.on 'submit', (e)=>
      e.preventDefault()
      e.stopPropagation()
      @create()

    @form.on 'click', '.action.commit', (e)=>
      e.preventDefault()
      e.stopPropagation()
      @create()

  create: ->
    if @form.find('input#folder_name').val() != ''
      @removeFailState()
      @setSavingState()
      @submit()


  hideFormMessages: ->
    @form.find('.folder_error').hide()
    @form.find('.folder_success').hide()
    @form.find('.folder_create').hide()

  setSavingState: ->
    @form.find('li.action.commit')
      .addClass 'saving'
      .append $('<div>').addClass('loader')

    @form.find('button[type=submit]')
      .val 'Creating folder and saving clipping(s)...'
      .prop 'disabled', true


  removeSavingState: ->
    @form.find('li.action.commit')
      .removeClass 'saving'
      .find $('.loader')
      .remove()

    @form.find('button[type=submit]')
      .val ''
      .prop 'disabled', false

  setSuccessState: (response)->
    folderHandler = this

    @removeSavingState()

    @form.find('button[type=submit]')
      .val 'Folder created and clipping added'
      .prop 'disabled', false

    # notify anyone listening in 1 sec so they can do their thing
    setTimeout(
      ()->
        folderHandler.modal.trigger('folderCreated', response)
        folderHandler.closeModal()
      1000
    )

  setFailState: (response)->
    @removeSavingState()

    @form.find('button[type=submit]')
      .val 'Create Folder'
      .prop 'disabled', false

    responseText = $.parseJSON response.responseText

    errorMessage = @modal.find '.folder_error'

    errorMessage.find('p .message').html(responseText.errors[0])
    errorMessage.show()

  removeFailState: ->
    errorMessage = @modal.find '.folder_error'

    errorMessage.find('p .message').html('')
    errorMessage.hide()

  submit: ->
    folderName = @form.find('input#folder_name').val()

    data = [
      {
        name: "folder[name]",
        value: folderName
      }
    ]

    # add appropriate params
    if @documentNumber
      data.push {
        name: "folder[document_numbers][]",
        value: @documentNumber
      }
    else if @clippingIds
      data.push {
        name: "folder[clipping_ids]",
        value: @clippingIds
      }


    folderCreate = $.ajax({
      url: '/my/folders',
      data: data,
      type: "POST",
      beforeSend: (xhr)->
        xhr.setRequestHeader(
          'X-CSRF-Token',
          $('meta[name="csrf-token"]').attr('content')
        )
    })

    folderCreate.done (response)=>
      track_folder_event('create', 1)
      track_clipping_event('add', @document_number, folderName)

      @setSuccessState(response)

    folderCreate.fail (response)=>
      @setFailState(response)

  closeModal: ->
    @modal.find('a.jqmClose').click()
