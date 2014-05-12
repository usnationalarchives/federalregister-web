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
    settings = {
      url: @commentFormEl().attr 'action'
      dataType: 'html'
      type: 'POST'
      data: @commentFormEl().serialize()
    }

    submitHandler = this

    $.extend settings, options

    $.ajax {
      url: settings.url
      type: settings.type
      dataType: settings.dataType
      data: settings.data
      success: (response)->
        submitHandler.success response
      error: (response)->
        submitHandler.error response
    }

  success: (response)->
    @_rollUpCommentAndReplace response, (response)=>
      successPage = $('<div>')
        .addClass 'comment_wrapper'
        .html response
        .hide()

      @ajaxCommentData
        .append successPage
      @ajaxCommentData
        .animate {height: successPage.css 'height'}, 800
      successPage
        .slideDown 800, =>
          @commentFormHandler.successPageReady()

      @commentFormStore().clearSavedFormState()

  error: (response)->
    @_rollUpCommentAndReplace response, (response)=>
      @commentFormHandler.commentFormLoadHandler.success response.responseText

  _rollUpCommentAndReplace: (response, replaceWith)->
    @ajaxCommentData = $('.ajax-comment-data')
    commentWrapper = @ajaxCommentData.find '.comment_wrapper'

    @ajaxCommentData
      .animate {height: '42px'}, 400
    @ajaxCommentData
      .scrollintoview {duration: 400}

    commentWrapper.slideUp 400, ->
      commentWrapper.remove()
      replaceWith response


