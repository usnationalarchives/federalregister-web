class @FR2.CommentForm
  constructor: (commentFormId, commentFormHandler)->
    @commentFormId = commentFormId
    @commentFormHandler = commentFormHandler

    @notSentFieldIds = [
      '#comment_confirmation_text',
      '#comment_confirm_submission_input'
    ]

    @uploadsInProgress = false

  initialize: ->
    @addFormEvents()
    @addCommentSecret()
    @setSubmitButtonState()
    @addSubmitButtonWarningModal()

  commentFormEl: ->
    if @_commentFormEl == null || @_commentFormEl == undefined || @_commentFormEl == []
      $( @commentFormId )
    else
      @_commentFormEl

  commentFormFileUploader: ->
    @commentFormHandler.commentFormFileUploader

  addFormEvents: ->
    @comboBoxChangeHandler()
    @removeErrorsOnChange()
    @maxCharacterWarning()
    @confirmCommentSubmission()
    @formSubmit()

  parseFields: ->
    fields = []
    $els = @commentFormEl().find('.inputs > ol > li')

    $els = @removeNotSentFields($els)

    _.each $els, (el)=>
      listItem = $(el)
      key = listItem.find('label').text().replace('*','')
      field = {'label': key}

      if listItem.hasClass('combo')
        input = listItem.find('select').first()
        if input.length > 0
          field.values = Array @getOptionValue(input)
        else
          field.values = Array @getItemValue(listItem, 'input')

      else if listItem.hasClass('stringish')
        field.values = Array @getItemValue(listItem, 'input')
      else if listItem.hasClass('text')
        field.values = Array @getItemValue(listItem, 'textarea')
      else if listItem.hasClass('select')
        input = listItem.find('select').first()
        field.values = Array @getOptionValue(input)
      else if listItem.hasClass('file')
        attachments = listItem.find('.attachments tr')

        attachment_names = _.map attachments, (el)->
          $(el).data('name')

        if attachment_names.length
          field.values =  attachment_names
        else
          Array 'None attached'

      fields.push field

    fields

  removeNotSentFields: ($els)->
    _.each @notSentFieldIds, (id)->
      $els = $els.filter("li:not(#{id})")

    $els

  getOptionValue: ($input)->
    $input.find('option[value="' + $input.val() + '"]').first().text()

  getItemValue: ($item, type)->
    $item.find(type).val()

  comboBoxChangeHandler: ->
    _.each @commentFormEl().find('li.combo'), (li)=>
      $li = $(li)
      dependencies = $li.data('dependencies')
      input = $li.find('input')

      @commentFormEl().find("select[name='comment[#{$li.data('dependent-on')}]']")
        .change ->
          parentSelect = $(this)
          parentValue = parentSelect.val()

          $li.find('select').remove()

          if dependencies[parentValue]
            currentValue = input.val()
            select = $("<select name='#{input.attr('name')}'><option></option></select>")

            _.map dependencies[parentValue], (options)->
              option = $('<option>')
              option
                .attr 'value', options[0]
                .text options[1]
              select.append option

            select.val currentValue

            input
              .prop 'disabled', true
              .hide()
              .val ''
              .after select
          else
            input
              .removeProp 'disabled'
              .show()

        .change()

  addCommentSecret: ->
    commentSecret = @commentFormEl().find '#comment_secret'

    if commentSecret.val() == ''
      commentSecret.val Math.random().toString(36).substring(2,16)

  removeErrorsOnChange: ->
    @commentFormEl().on 'change', 'select', (e)->
      select = $(this)

      select
        .siblings '.inline-errors'
        .remove()
      select
        .closest 'li'
        .removeClass 'error'

    @commentFormEl().on 'change keyup', 'li.error.input', (e)->
      FR2.FormUtils.validateField this

  maxCharacterWarning: ->
    @commentFormEl().on 'change keyup', 'li.input[data-max-size]', ()->
      FR2.FormUtils.enforceCharactersRemaining this

  submitButtonWrapper: ->
    @commentFormEl().find '.button.commit'

  commentConfirmationCheckbox: ->
    @commentFormEl().find '#comment_confirm_submission'

  confirmCommentSubmission: ->
    @commentFormEl().on 'change', @commentConfirmationCheckbox(), ()=>
      @setSubmitButtonState()

  setSubmitButtonState: ()->
    if @commentConfirmationChecked() && @uploaderReady()
      @enableSubmitButton()
    else
      @disableSubmitButton()

  commentConfirmationChecked: ->
    @commentConfirmationCheckbox().is ':checked'

  formSubmit: ->
    @commentFormEl().on 'click', '.button.commit:not(.submitting, .disabled)', (e)=>
      e.preventDefault()

      @commentFormHandler.submitCommentForm()

  storeComment: ->
    @commentFormHandler.storeComment()

  enableSubmitButton: ->
    @submitButtonWrapper()
      .removeClass 'disabled'
      .find 'input'
      .removeProp 'disabled'

  disableSubmitButton: ->
    @submitButtonWrapper()
      .addClass 'disabled'
      .find 'input'
      .prop 'disabled', true

  # acts as getter/setter
  uploaderReady: (status)->
    if status?
      @uploaderReadyStatus = status
      @setSubmitButtonState()

    @uploaderReadyStatus

  getSubmitButtonState: ->
    if ! @uploaderReady()
      if @commentFormFileUploader().uploaderHasErrors()
        "Some of your files have errors. Please remove the files and try again."
      else if @commentFormFileUploader().uploaderInProgress()
        "Your files are still being uploaded. Please wait until they are complete and try again."
    else if ! @commentConfirmationChecked()
      "Please read and confirm the statement regarding the submission of personal information."
    else
      false

  addSubmitButtonWarningModal: ->
    @submitButtonWrapper().on 'click', (e)=>
      if @submitButtonWrapper().hasClass 'disabled'
        e.preventDefault()
        e.stopPropagation()

        modalTitle = 'Unable to Submit Comment'
        modalHtml  = @getSubmitButtonState()

        display_fr_modal modalTitle, modalHtml, @submitButtonWrapper()
