class @FR2.CommentFormStore
  constructor: (commentFormHandler)->
    @commentFormHandler = commentFormHandler

    @recentlySaved = false
    @saveTimeoutDuration = 5000
    @saveTimeout = null

  commentFormEl: ->
    @commentFormHandler.commentForm.commentFormEl()

  documentNumber: ->
    @commentFormHandler.formWrapper.data('document-number')

  getStoredComment: ->
    amplify.store @documentNumber()

  setStoredComment: (commentVal)->
    if commentVal == ""
      commentVal = null

    amplify.store @documentNumber(), commentVal

  hasStoredComment: ->
    @getStoredComment()? &&
      Object.keys(@getStoredComment()).length &&
      # TODO: refine this last condition as we figure out how to
      # deal with params and secrets
      Object.keys(@getStoredComment()) != ["comment[secret]"]

  addStorageEvents: ->
    @commentFormEl().on 'keyup change', ':input', ()=>
      if !@recentlySaved && @saveTimeout == null
        @recentlySaved = true

        saveCommentAndResetTimeout = ()=>
          @setStoredComment @serializeForm()
          @recentlySaved = false
          @saveTimeout = null

        @saveTimeout = setTimeout(
          saveCommentAndResetTimeout,
          @saveTimeoutDuration
        )

  serializeForm: ->
    formInputs = @commentFormEl().find ':input'

    formInputs = formInputs
      .filter ':input[name!=authenticity_token]'
      .filter ':input[name!=utf8]'
      .filter ':input[name!="comment[confirm_submission]"]'
      .filter ':input[name!="commit"]'

    _.reduce formInputs, (memo, input)->
      if $(input).val() != ""
        memo[input.name] = input.value
      memo
    , {}

  clearSavedFormState: ->
    @setStoredComment null

  storeComment: ->
    @setStoredComment @serializeForm()

