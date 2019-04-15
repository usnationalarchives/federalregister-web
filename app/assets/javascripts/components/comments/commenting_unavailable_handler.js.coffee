class @FR2.CommentingUnavailableHandler
  constructor: ($formWrapper)->
    this.formWrapper = $formWrapper
    this._bindClickListener()

  _bindClickListener: ->

    context = this
    @formWrapper.on 'click', 'a#start_comment', (e) ->
      e.preventDefault()
      location = e.target.getAttribute('href')

      FR2.Modal.displayModal(
        'Direct Commenting Unavailable',
        "<p>Submitting a formal comment directly via federalregister.gov is not available for this document.  #{context._optionalMessage()}However, you can click the button below to view more information on alternate methods of comment submission.</p></br><a class='fr_button medium primary jqm-close-js'>View Additional Information</a>",
        {
          'modalId': "#commentingUnavailableModal",
          'alternateModalCloseSelector': '.jqm-close-js',
          'onHide':  (hsh) ->
            # hash object
            #   w: (jQuery object) The modal element
            #   c: (object) The modal's options object
            #   o: (jQuery object) The overlay element
            #   t: (DOM object) The triggering element
            hsh.w.hide()
            hsh.o.remove()
            $('html, body').stop().animate(
              {scrollTop: $(location).offset().top},
              1500,
              () -> window.location.hash = location
            )
        },
      )

  _optionalMessage: ->
    if this._isParticipatingAgency()
      ""
    else
      "The agency does not participate in commenting via regulations.gov.  "

  _isParticipatingAgency: ->
    this.formWrapper.data('reg-gov-participating-agency')

