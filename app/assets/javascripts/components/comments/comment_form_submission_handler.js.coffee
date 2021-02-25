class @FR2.CommentFormSubmissionHandler
  constructor: (commentFormHandler)->
    @commentFormHandler = commentFormHandler

  commentFormStore: ->
    @commentFormHandler.commentFormStore

  commentForm: ->
    @commentFormHandler.commentForm

  commentFormEl: ->
    @commentForm().commentFormEl()

  submitButton: ->
    @commentFormEl().find '.commit.button'

  submit: ->
    @styleSubmitButton()
    @submitForm()

  styleSubmitButton: ->
    @submitButton()
      .addClass 'submitting'
      .find 'input'
      .prop 'disabled', true
      .attr 'value', 'Submitting Comment'

  submitForm: (options)->
    # TODO: implement actual form submissions
    console.log('Submitting form:')
    _.each @commentFormEl().find('input,textarea'), (el) ->
      console.log(el.name + ': ' + el.value)
    settings = {
     url: @commentFormEl().attr 'action'
     dataType: 'html'
     type: 'POST'
     data: @commentFormEl().serialize()
    }

    agency = @commentFormEl().data('agency')
    documentNumber = @commentFormEl().data('document-number')

    submitHandler = this

    $.extend settings, options

    #TODO: This is a stub for comment form submission.  It should be made dynamic with the content of the actual reg.gov response.
    settings.url = "/my/documents/#{documentNumber}/comments"
    settings.data = {
      "serializedForm": @commentFormEl().serialize(),
      "reg_gov_response_data": {
          "id": "klb-dy99-pl2c",
          "type": "comments",
          "attributes": {
              "zip":                 null,
              "country":             null,
              "lastName":            "Anonymous",
              "city":                null,
              "receiveDate":         "2021-02-18T21:37:52.238+0000",
              "submissionKey":       null,
              "submitterRep":        null,
              "userId":              "b3bda779-8165-4c17-ad31-f3389d77af3c",
              "organizationType":    null,
              "firstName":           "Anonymous",
              "submissionType":      "API",
              "submitterType":       "ANONYMOUS",
              "commentOnDocumentId": "CPSC-2013-0025-0004",
              "stateProvinceRegion": null,
              "phone":               null,
              "organization":        null,
              "sendEmailReceipt":    false,
              "numItemsReceived":    0,
              "files":               null,
              "comment":             "test comment",
              "category":            null,
              "email":               null
          }
      }
    }

    $.ajax {
     url: settings.url
     type: settings.type
     dataType: settings.dataType
     data: settings.data
     success: (response)->
       submitHandler.success response
       submitHandler.trackCommentFormSubmissionSuccess()

     error: (response)->
       if response.status == 422
         submitHandler.trackCommentFormSubmissionError(
           'Comment: Submit Comment Form Validation Error'
         )
       else
         submitHandler.trackCommentFormSubmissionError(
           "Comment: Submit Comment Form Error #{response.error}"
         )

       submitHandler.error response
    }

  trackCommentFormSubmissionSuccess: ->
    @commentFormHandler.trackCommentEvent 'Comment: Submit Comment Form Success'

  trackCommentFormSubmissionError: (category)->
    @commentFormHandler.trackCommentEvent category

  success: (response)->
    @_rollUpCommentAndReplace response, (response)=>
      successPage = $('<div>')
        .addClass 'comment_wrapper'
        .html response
        .hide()

      # TODO: confirm removal: now reusing same form instead of fetching
      @ajaxCommentData
        .append successPage
      @ajaxCommentData
        .animate {height: successPage.css 'height'}, 800
      successPage
        .slideDown 800, =>
          @commentFormHandler.successPageReady()

      @commentFormStore().clearSavedFormState()

  error: (response)->
    if response.getResponseHeader('Regulations-Dot-Gov-Over-Rate-Limit') == "1"
      reggov_url = @commentFormHandler.commentFormLoadHandler.formWrapper().data('reggov-comment-url')

      modalTitle = "Over Rate Limit"
      modalHtml = "
        <p>
          We were unable to successfully submit your comment at this time because Regulations.gov
          has received too many comments in the last hour.
        </p>
        <p>
          Please try submitting your comment again later, attempt to comment directly via Regulations.gov at
          <a href='#{reggov_url}'>#{reggov_url}</a>, or via any other method
          described in the document.
        </p>"
      FR2.Modal.displayModal modalTitle, modalHtml

    @_rollUpCommentAndReplace response, (response)=>
      commentPage = $('<div>')
        .addClass 'comment_wrapper'
        .html response.responseText
        .hide()

      # TODO: confirm removal: now reusing same form instead of fetching
      @ajaxCommentData
        .append commentPage
      @ajaxCommentData
        .animate {height: commentPage.css 'height'}, 800
      commentPage
        .slideDown 800, =>
          @commentFormHandler.commentFormReady()

  _rollUpCommentAndReplace: (response, replaceWith)->
    @ajaxCommentData = $('.ajax-comment-data')
    commentWrapper = $('.comment_wrapper')

    @ajaxCommentData
      .animate {height: '42px'}, 400
    $('#comment-bar.comment')
      .scrollintoview {duration: 400}

    commentWrapper.slideUp 400, ->
      #TODO: Formerly, the replaceWith function was being called to replace with page contents.  For some reason this wasn't working with the new code (likely because we're not replacing the form in totality any longer).  This is a replacement call for rendering.
      commentWrapper.html(response).slideDown 800
      # TODO: confirm removal: now reusing same form instead of fetching
      # commentWrapper.remove()
      # replaceWith response
