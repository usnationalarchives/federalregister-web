class @FR2.CommentFormLoadHandler
  constructor: (commentFormHandler)->
    @commentFormHandler = commentFormHandler
    @commentFormStore = @commentFormHandler.commentFormStore

    @setup()

  formWrapper: ->
    # This is now only comment-bar which sits on top of comment_wrapper.
    # We previously inserted the comment form into this div.
    @commentFormHandler.formWrapper

  commentLink: ->
    @formWrapper().find 'a#start_comment'

  commentWrapper: ->
    @commentFormHandler.commentWrapper()

  setup: ->
    @documentNumber = @formWrapper().data 'document-number'

  uiTriggerLoading: ->
    @commentFormHandler.refreshDocStickyNav()

  loadStoredComment: ->
    if @commentFormStore.hasStoredComment()
      @commentFormHandler.showReloadedCommentInformationBox()
      @commentFormHandler
        .commentForm
        .loadComment(@commentFormStore.getStoredComment())

  load: ->
    @uiTriggerLoading()
    @loadForm()
    @loadStoredComment()
    @trackOpenComment()

  trackOpenComment: ->
    $.ajax
      url: "/my/documents/#{@documentNumber}/comments/new"

  loadForm: ->
    loadHandler = this
    loadHandler.success()

  trackCommentFormOpenSuccess: ()->
    @commentFormHandler.trackCommentEvent 'Comment: Open Comment Form Success'

  trackCommentFormOpenError: (error)->
    @commentFormHandler.trackCommentEvent "Comment: Open Comment Form #{error}"

  success: ->
    @generateCommentForm()

    commentFormWrapper = @commentFormWrapper

    @commentFormHandler.updateCommentHeader()

    commentFormWrapper.slideDown 800, () =>
      @commentFormHandler.commentFormReady()
      @addTrackingEvents()
      @trackCommentFormOpenSuccess()

  error: (response)->
    if response.getResponseHeader('Regulations-Dot-Gov-Problem') == "1" || response.getResponseHeader('Comments-No-Longer-Accepted') == "1" || response.getResponseHeader('Regulations-Dot-Gov-Over-Rate-Limit') == "1"
      responseText = JSON.parse response.responseText
      modalTitle = responseText.modalTitle
      modalHtml  = responseText.modalHtml

      if response.getResponseHeader('Regulations-Dot-Gov-Problem') == "1"
        @trackCommentFormOpenError 'Regulations.gov Error'
      else if response.getResponseHeader('Comments-No-Longer-Accepted') == "1"
        @trackCommentFormOpenError 'Comments No Longer Accepted Error'
      else if response.getResponseHeader('Regulations-Dot-Gov-Over-Rate-Limit') == "1"
        @trackCommentFormOpenError 'Over Rate Limit Error'

      siteNotification = ''

      $.ajax {
        async: false,
        url: '/api/v1/site_notifications/comment',
        dataType: 'json'
        success: (response)->
          if response.active
            siteNotification = "<div class='#{response.notification_type}'>#{response.description}</div>"

      }

      modalHtml = "#{siteNotification} #{modalHtml}"

    else
      reggov_url = @formWrapper().data('reggov-comment-url')
      modalTitle = "We're sorry something <br> went wrong"
      modalHtml = "
        <p>We're sorry we are currently unable to submit your comment to Regulations.gov.</p>
        <p>
          You may want try again in a few moments or attempt to comment via Regulations.gov: <br>
          <a href='#{reggov_url}'>#{reggov_url}</a>,
          <br>or via any other method described in the document.
        </p>
      "
      @trackCommentFormOpenError 'FederalRegister.gov Error'

      siteNotification = ''

      $.ajax {
        async: false,
        url: '/api/v1/site_notifications/comment',
        dataType: 'json'
        success: (response)->
          if response.active
            siteNotification = "<div class='#{response.notification_type}'>#{response.description}</div>"

      }

      modalHtml = "#{siteNotification} #{modalHtml}"

    FR2.Modal.displayModal modalTitle, modalHtml

  generateCommentForm: (response)->
    @commentFormWrapper = $('.comment_wrapper')

    @commentFormHandler.commentForm = new FR2.CommentForm('#new_comment', @commentFormHandler)
    @commentForm = @commentFormHandler.commentForm

    @commentFormHandler.addStorageEvents()

  addTrackingEvents: ->
    @commentWrapper().on 'click', '.reg_gov_posting_guidelines', ()=>
      @commentFormHandler.trackCommentEvent "Comment Instructions: Regulations.gov Agency Posting Guidelines Modal"

    @commentWrapper().on 'click', '.reg_gov_alternative_ways_to_comment', ()=>
      @commentFormHandler.trackCommentEvent "Comment Instructions: Regulations.gov Alternative Ways to Comment Modal"

    @commentWrapper().on 'click', '.alternative_ways_to_comment.addresses', ()=>
      @commentFormHandler.trackCommentEvent "Comment Instructions: FederalRegister.gov Alternative Ways to Comment"

    @commentWrapper().on 'click', '.comment_preview', ()=>
      @commentFormHandler.trackCommentEvent "Comment Form: Comment Preview Modal"

    @commentWrapper().on 'click', '#comment-privacy-policy', ()=>
      @commentFormHandler.trackCommentEvent "Comment Footer: Regulations.gov Privacy Policy"

    @commentWrapper().on 'click', '#comment-user-notice', ()=>
      @commentFormHandler.trackCommentEvent "Comment Footer: Regulations.gov User Notice"

    @commentWrapper().on 'click', '.attachment_requirements', ()=>
      @commentFormHandler.trackCommentEvent "Comment Instructions: Regulations.gov Attachment Requirements Modal"
