class @FR2.CommentingUnavailableHandler
  constructor: ($formWrapper, modalText, onHideHandler)->
    this.formWrapper = $formWrapper
    this.modalText   = modalText
    if onHideHandler == false
      this.onHideHandler = () -> # no-op
    else
      this.onHideHandler = this._defaultOnHideHandler
    this._bindClickListener()

  _bindClickListener: ->

    context = this
    @formWrapper.on 'click', 'a#start_comment', (e) ->
      e.preventDefault()
      location = e.target.getAttribute('href')

      FR2.Modal.displayModal(
        'Submit a Formal Comment',
        context.modalText,
        {
          'modalId': "#commentingUnavailableModal",
          'alternateModalCloseSelector': '.jqm-close-js',
          'onHide': context.onHideHandler()
        },
      )

  _defaultOnHideHandler: ->
    (hsh) ->
      # hash object
      #   w: (jQuery object) The modal element
      #   c: (object) The modal's options object
      #   o: (jQuery object) The overlay element
      #   t: (DOM object) The triggering element
      hsh.w.hide()
      hsh.o.remove()
      location = $("a#start_comment").attr('href')
      $('html, body').stop().animate(
        {scrollTop: $(location).offset().top},
        1500,
        () -> window.location.hash = location
      )
      $(location).next().addClass('highlight')
