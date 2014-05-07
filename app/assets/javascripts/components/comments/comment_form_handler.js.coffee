class @FR2.CommentFormHandler
  constructor: ($formWrapper)->
    @formWrapper = $formWrapper

    @commentFormStore = new FR2.CommentFormStore this
    @commentFormLoadHandler = new FR2.CommentFormLoadHandler this
    @commentFormSubmissionHandler = new FR2.CommentFormSubmissionHandler this
    @commentFormFileUploader = new FR2.CommentFormFileUploader this
    @commentFormSuccessHandler = new FR2.CommentFormSuccessHandler this

    @startComment()

  commentFormReady: ->
    @removeEvents()

    @commentForm.initialize()
    @commentFormFileUploader.initialize()
    @commentFormStore.addStorageEvents()

    @addEvents()
    @decorate()

  successPageReady: ->
    @commentFormSuccessHandler.initialize()

  removeEvents: ->
    @formWrapper.unbind()

  addEvents: ->
    @commentPreview()
    @startCommentOver()

  decorate: ->
    @addPublicIcons()
    @addTooltipToPublicIcons()
    @improveUploadButton()

  commentFormEl: ->
    @commentForm.commentFormEl()

  commentPreview: ->
    @commentFormEl().on 'click', '.comment_preview', (e)=>
      e.preventDefault()

      fields = @commentForm.parseFields()
      html = @renderCommentSummary fields

      Handlebars.registerPartial 'comment_summary', $('#comment-summary-template').html()
      source = $('#comment-summary-template').html()
      template = Handlebars.compile source

      modal = $( template({"fields": fields}) )
      $('body').append modal
      modal.find(".jqmClose").on 'click', (e)->
        modal.remove()

      modal.addClass('jqmWindow alternative-comment-modal')
      modal.jqm({
        modal: true,
        toTop: true
      })
      modal.jqmShow().centerScreen()

  renderCommentSummary: (fields)->
    source = $('#comment-summary-template').html()
    template = Handlebars.compile source
    template fields

  addPublicIcons: ->
    items = @commentFormEl().find '.inputs li'

    _.each items, (li)->
      $li = $(li)
      if $li.hasClass 'public'
        el = $li
          .find ' > :input'
          .last()

        if el.prop('id') == 'comment_general_comment' || el.prop('id') == 'fileupload'
          tooltipGravity = 'e'
        else
          tooltipGravity = 'w'

        el
          .after(
            $('<span>')
              .addClass 'public icon-fr2 icon-fr2-globe'
              .data 'tooltip-gravity', tooltipGravity
          )

  addTooltipToPublicIcons: ->
    @commentFormEl()
      .find '.inputs span.public'
      .tipsy({
        gravity: ()->
          $(this).data 'tooltip-gravity'
        fallback: "Information entered in this field will be publically viewable on Regulations.gov"
        fade: true
        offset: -8
        className: 'form-tooltip'
      })
      .mouseenter ()->
        tooltip = $('.tipsy.form-tooltip').first()

        if tooltip.hasClass 'tipsy-e'
          leftPosition = 257
        else
          leftPosition = 13

        # we modify the css with the .form-tooltip class so
        # we need to reposition the tooltip so that it's centered
        tooltip
          .css(
            'left',
            tooltip
              .position()
              .left + leftPosition
          )
         .css(
            'top',
            tooltip
              .position()
              .top - 23
          )


  improveUploadButton: ->
    addFileButton = $('<div>')
      .addClass 'add_file button'
      .text 'Add a file'
      .prepend(
        $('<span>').addClass 'icon-fr2 icon-fr2-add'
      )

    fileUploadButton = @commentFormEl().find '#fileupload'

    fileUploadButton.after addFileButton

    @commentFormEl().on 'click', '.add_file', ()->
      fileUploadButton.trigger 'click'

    fileUploadButton.hide();

  loadCommentForm: ->
    @commentFormLoadHandler.load()

  submitCommentForm: ->
    @commentFormStore.storeComment()
    @commentFormSubmissionHandler.submit()

  startComment: ->
    @formWrapper.on 'click', 'a#start_comment[data-comment=1]', (e)=>
      e.preventDefault()
      @loadCommentForm()

  startCommentOver: ->
    @commentFormEl().on 'click', 'a#comment-start-over', (e)=>
      e.preventDefault()

      @commentFormStore.clearSavedFormState()

      ajaxCommentData = $('.ajax-comment-data')
      commentWrapper = ajaxCommentData.find '.comment_wrapper'

      ajaxCommentData
        .animate {height: '42px'}, 400
      ajaxCommentData
        .scrollintoview {duration: 400}

      commentWrapper.slideUp 400, =>
        commentWrapper.remove()
        @loadCommentForm()

  updateCommentHeader: ->
    flashMessage = $('#flash_message.comment p')

    flashMessage
      .find '.button'
      .fadeOut 400, ()->
        flashMessage.html 'You are submitting an official comment to Regulations.gov. <img alt="Regulations.gov Logo" src="/my/assets/regulations_dot_gov_logo.png" class="reg_gov_logo">'

  storeComment: ->
    @commentFormStore.storeComment()
