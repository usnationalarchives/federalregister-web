class @FR2.CommentFormLoadHandler
  constructor: (commentFormHandler)->
    @commentFormHandler = commentFormHandler
    @commentFormStore = @commentFormHandler.commentFormStore

    @setup()

  formWrapper: ->
    @commentFormHandler.formWrapper

  commentLink: ->
    @formWrapper().find 'a#start_comment'

  ajaxCommentData: ->
    $('.ajax-comment-data')

  setup: ->
    @commentDiv = $('<div>')
      .addClass 'ajax-comment-data'
      .hide()

    @loadingDiv = $('<div>')
      .addClass 'loading'
      .append(
        $('<span>')
          .addClass 'loader'
          .html 'Loading Comment Form'
          .append(
            $('<span>')
              .addClass 'spinner'
          )
      )

    @documentNumber = @formWrapper().data 'document-number'

    @formWrapper().after @commentDiv

  uiTriggerLoading: ->
    @commentDiv.append @loadingDiv
    @commentDiv.slideDown 800

  generateAjaxOptions: ->
    if @commentFormStore.hasStoredComment()
      @ajaxOptions = {
        url: "/my/documents/#{@documentNumber}/comments/reload"
        type: 'POST'
        data: @commentFormStore.getStoredComment()
      }
    else
      @ajaxOptions = {
        url: "/my/documents/#{@documentNumber}/comments/new"
      }

  load: ->
    @uiTriggerLoading()
    @generateAjaxOptions()
    @loadForm()


  loadForm: ->
    settings = {
      url: ''
      dataType: 'html'
      type: 'GET'
      data: ''
      timeout: 30000
    }

    loadHandler = this

    $.extend settings, @ajaxOptions

    $.ajax {
      url: settings.url
      type: settings.type
      dataType: settings.dataType
      data: settings.data
      timeout: settings.timeout
      success: (response)->
        loadHandler.success response
      error: (response)->
        loadHandler.error response
    }

  trackCommentFormOpenSuccess: ()->
    @commentFormHandler.trackCommentEvent 'Comment: Open Comment Form Success'

  trackCommentFormOpenError: (error)->
    @commentFormHandler.trackCommentEvent "Comment: Open Comment Form #{error}"

  success: (response)->
    @generateCommentForm response

    commentFormWrapper = @commentFormWrapper

    @loadingDiv.fadeOut 600, ()=>
      @commentFormHandler.updateCommentHeader()

      ajaxCommentData = @ajaxCommentData()
      ajaxCommentData
        .css 'height', '42px'
        .animate(
          { height: commentFormWrapper.css 'height' }, 800, ()->
            ajaxCommentData.css 'height', 'auto'
        )

      commentFormWrapper.slideDown 800, ()=>
        @commentFormHandler.commentFormReady()
        @addTrackingEvents()
        @trackCommentFormOpenSuccess()

  error: (response)->
    if response.getResponseHeader('Regulations-Dot-Gov-Problem') == "1"
      responseText = JSON.parse response.responseText
      modalTitle = responseText.modalTitle
      modalHtml  = responseText.modalHtml
      @trackCommentFormOpenError 'Regulations.gov Error'
    else
      modalTitle = "We're sorry something went wrong"
      modalHtml = "We've encountered an error and we have been notified. Please try again later."
      @trackCommentFormOpenError 'FederalRegister.gov Error'

    FR2.Modal.displayModal modalTitle, modalHtml

    $('.ajax-comment-data').fadeOut 600

  generateCommentForm: (response)->
    @commentFormWrapper = $('<div>')
      .addClass 'comment_wrapper'
      .html response
      .hide()

    @commentDiv.append @commentFormWrapper

    @commentFormHandler.commentForm = new FR2.CommentForm('#new_comment', @commentFormHandler)
    @commentForm = @commentFormHandler.commentForm

    @commentFormHandler.addStorageEvents()

  addTrackingEvents: ->
    @ajaxCommentData().on 'click', '.reg_gov_comment_tips', ()=>
      @commentFormHandler.trackCommentEvent "Comment Instructions: Regulations.gov Comment Tips"

    @ajaxCommentData().on 'click', '.reg_gov_posting_guidelines', ()=>
      @commentFormHandler.trackCommentEvent "Comment Instructions: Regulations.gov Agency Posting Guidelines Modal"

    @ajaxCommentData().on 'click', '.reg_gov_alternative_ways_to_comment', ()=>
      @commentFormHandler.trackCommentEvent "Comment Instructions: Regulations.gov Alternative Ways to Comment Modal"

    @ajaxCommentData().on 'click', '.alternative_ways_to_comment.addresses', ()=>
      @commentFormHandler.trackCommentEvent "Comment Instructions: FederalRegister.gov Alternative Ways to Comment"

    @ajaxCommentData().on 'click', '.comment_preview', ()=>
      @commentFormHandler.trackCommentEvent "Comment Form: Comment Preview Modal"

    @ajaxCommentData().on 'click', '#comment-privacy-policy', ()=>
      @commentFormHandler.trackCommentEvent "Comment Footer: Regulations.gov Privacy Policy"

    @ajaxCommentData().on 'click', '#comment-user-notice', ()=>
      @commentFormHandler.trackCommentEvent "Comment Footer: Regulations.gov User Notice"

    @ajaxCommentData().on 'click', '.attachment_requirements', ()=>
      @commentFormHandler.trackCommentEvent "Comment Instructions: Regulations.gov Attachment Requirements Modal"
