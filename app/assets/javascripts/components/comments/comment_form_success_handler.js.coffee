class @FR2.CommentFormSuccessHandler
  constructor: (commentFormHandler)->
    @commentFormHandler = commentFormHandler

  initialize: ->
    @add_events()
    @updateCommentHeader()

  formWrapper: ->
    @commentFormHandler.formWrapper

  ajaxCommentData: ->
    $('.ajax-comment-data')

  add_events: ->
    @printComment()

  updateCommentHeader: ->
    flashMessage = $('#flash_message.comment p')

    flashMessage
      .closest 'div'
      .removeClass 'open'

    flashMessage
      .html 'You have successfully submitted an official comment to Regulations.gov. <img alt="Regulations.gov Logo" src="/my/assets/regulations_dot_gov_logo.png" class="reg_gov_logo">'


  printComment: ->
    @ajaxCommentData().on 'click', 'a#print-comment', (e)->
      e.preventDefault()

      link = $(this)

      modalTitle    = 'Print your comment'
      modalTemplate = $("#comment-print-summary-template")
      modalData     = link.data('comment-data')

      compiledTemplate = Handlebars.compile modalTemplate.html()
      modalHtml        = compiledTemplate({
        fields: modalData
        document_details: link.data 'current-document-details'
        comment_details: link.data 'comment-details'
      })

      display_fr_modal modalTitle, modalHtml, link, {modalClass: "print_modal"}

      $('body').addClass 'hide_body_content'

    @formWrapper().on 'modalClose', 'a#print-comment', ->
      $('body').removeClass 'hide_body_content'

    $('body').on 'click', '#fr_modal .print_button', (e)->
      e.preventDefault()
      window.print()
