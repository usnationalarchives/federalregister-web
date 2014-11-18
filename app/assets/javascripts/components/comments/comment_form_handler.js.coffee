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
    @previewComment()
    @startCommentOver()

  decorate: ->
    @addPublicIcons()
    @addTooltipToPublicIcons()
    @improveUploadButton()

  commentFormEl: ->
    @commentForm.commentFormEl()

  previewComment: ->
    @commentFormEl().on 'click', '.comment_preview', (e)=>
      e.preventDefault()

      fields = @commentForm.parseFields()
      html = @renderCommentSummary fields

      Handlebars.registerPartial 'comment_summary', $('#comment-summary-template').html()

      modalTitle    = 'Preview your comment'
      modalTemplate = $('#comment-summary-template')
      modalData     = fields

      compiledTemplate = Handlebars.compile modalTemplate.html()
      modalHtml        = compiledTemplate({
        fields: modalData
      })

      source = $('#comment-summary-template').html()
      template = Handlebars.compile source

      display_fr_modal(
        modalTitle,
        modalHtml,
        $('body'),
        {modalClass: "comment-preview-modal"}
      )

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
        gravity: ->
          $(this).data 'tooltip-gravity'
        title: ->
          tooltip = $(this).siblings('input').data('tooltip')
          if tooltip?
            tooltip
          else
            "Information entered in this field will be publically viewable on Regulations.gov"
        fade: true
        offset: -8
        className: ->
          "form-tooltip #{$(this).siblings('input').prop('type')}"
      })
      .mouseenter ()->
        tooltip = $('.tipsy.form-tooltip').first()

        if tooltip.hasClass 'tipsy-e'
          if tooltip.hasClass 'file'
            leftPosition = 250
          else
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

  fileUploadButton: ->
    @commentFormEl().find '#fileupload'

  fileUploadButtonWrapper: ->
    @commentFormEl().find '.fileupload-button'

  improveUploadButton: ->
    addFileButton = $('<div>')
    addFileButton
      .addClass 'add_file button'
      .text 'Add a file'
      .prepend(
        $('<span>').addClass 'icon-fr2 icon-fr2-add'
      )

    @fileUploadButtonWrapper().append addFileButton

    @fileUploadButton().on 'hover', ()=>
      addFileButton.toggleClass('hover');

  loadCommentForm: ->
    @commentFormLoadHandler.load()

  submitCommentForm: ->
    @commentFormStore.storeComment()
    @trackCommentFormSubmitStart()
    @commentFormSubmissionHandler.submit()

  startComment: ->
    @formWrapper.on 'click', 'a#start_comment[data-comment=1]', (e)=>
      e.preventDefault()
      @trackCommentFormOpenStart()
      @loadCommentForm()

  trackCommentFormOpenStart: ->
    @trackCommentEvent 'Comment: Open Comment Form Start'

  trackCommentFormStartOver: ->
    @trackCommentEvent 'Comment: Comment Form Start Over'

  trackCommentFormSubmitStart: ->
    @trackCommentEvent 'Comment: Submit Comment Form Start'

  trackCommentEvent: (category)->
    wrapper = $('#flash_message')

    agency = wrapper.data('reggov-agency')
    documentNumber = wrapper.data('document-number')

    FR2.Analytics.trackCommentEvent category, agency, documentNumber

  startCommentOver: ->
    @commentFormEl().on 'click', 'a#comment-start-over', (e)=>
      e.preventDefault()

      @trackCommentFormStartOver()

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
        flashMessage
          .closest 'div'
          .addClass 'open'

        flashMessage
          .html '<div class="byline">You are submitting an official comment to Regulations.gov. <br> Comments are due ' + $('.comment_form_wrapper').data('comment-due') + '.</div> <img alt="Regulations.gov Logo" src="/my/assets/regulations_dot_gov_logo.png" class="reg_gov_logo">'

  storeComment: ->
    @commentFormStore.storeComment()

  addStorageEvents: ->
    @commentFormStore.addStorageEvents()
