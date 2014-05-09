class @FR2.CommentFormLoadHandler
  constructor: (commentFormHandler)->
    @commentFormHandler = commentFormHandler
    @commentFormStore = @commentFormHandler.commentFormStore

    @setup()

  formWrapper: ->
    @commentFormHandler.formWrapper

  commentLink: ->
    @formWrapper().find 'a#start_comment'

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
      )

    @documentNumber = @formWrapper().data 'document-number'

    @formWrapper().after @commentDiv

  uiTriggerLoading: ->
    @commentDiv.append @loadingDiv
    @commentDiv.slideDown 800

  generateAjaxOptions: ->
    if @commentFormStore.hasStoredComment()
      @ajaxOptions = {
        url: "/my/articles/#{@documentNumber}/comments/reload"
        type: 'POST'
        data: @commentFormStore.getStoredComment()
      }
    else
      @ajaxOptions = {
        url: "/my/articles/#{@documentNumber}/comments/new"
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

  success: (response)->
    @generateCommentForm response

    commentFormWrapper = @commentFormWrapper

    @loadingDiv.fadeOut 600, ()=>
      @commentFormHandler.updateCommentHeader()

      ajaxCommentData = $('.ajax-comment-data')
      ajaxCommentData
        .css 'height', '42px'
        .animate(
          { height: commentFormWrapper.css 'height' }, 800, ()->
            ajaxCommentData.css 'height', 'auto'
        )

      commentFormWrapper.slideDown 800, ()=>
        @commentFormHandler.commentFormReady()


  error: (response)->
    window.location = $(@commentLink()).attr 'href'

  generateCommentForm: (response)->
    @commentFormWrapper = $('<div>')
      .addClass 'comment_wrapper'
      .html response
      .hide()

    @commentDiv.append @commentFormWrapper

    @commentFormHandler.commentForm = new FR2.CommentForm('#new_comment', @commentFormHandler)
    @commentForm = @commentFormHandler.commentForm

    @commentFormHandler.addStorageEvents()
