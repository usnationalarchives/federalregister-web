class @FR2.EmailAFriend
  constructor: (@documentNumber)->
    #noop

  display: ->
    FR2.Modal.displayModal(
      'Email the Following Document',
      '<div class="wrapper"><div class="loader"></div></div>',
      {modalClass: 'email-a-friend-modal wide'}
    )

    @modal = $('#fr_modal')
    @form = @modal.find('form')


    form = $.ajax({
      url: "/documents/#{@documentNumber}/emails/new",
      dataType: "html"
    })

    form.always (response)=>
      @modal
        .find('.loader')
        .replaceWith(response)

      @disableSubmit()

      @modal.on 'change', 'input', (e)=>
        if @validForm()
          @enableSubmit()
        else
          @disableSubmit()

      @modal.on 'submit', 'form', (e)=>
        e.preventDefault()
        @submitForm()

      @modal.on 'click', 'form .action.commit', (e)=>
        e.preventDefault()
        @submitForm()

  disableSubmit: ->
    @modal.find('form .action.commit').addClass('disabled')

  enableSubmit: ->
    @modal.find('form .action.commit').removeClass('disabled')

  enabled: ->
    ! @modal.find('form .action.commit').hasClass('disabled')

  validForm: ->
    $('input[name="entry_email[sender]"]').val() != "" &&
      $('input[name="entry_email[recipients]"]').val() != ""

  submitForm: ->
    if @enabled() && ! @submitting()
      @addLoaderToButton()

      form = $.ajax({
        url: "/documents/#{@documentNumber}/emails",
        type: 'POST',
        data: @modal.find('form').serializeArray()
      })

      form.done (response)=>
        @submitSuccess(response)

      form.fail (response)=>
        @submitFailure(response)

      form.always =>
        @removeLoaderFromButton()

  addLoaderToButton: ->
    button = @modal.find('form .action.commit')

    button.append $('<div>').addClass('loader')
    button.addClass('submitting')

  removeLoaderFromButton: =>
    button = @modal.find('form .action.commit')

    button.find('.loader').remove()
    button.removeClass('submitting')

  submitting: ->
    @modal.find('form .action.commit').hasClass('submitting')

  submitSuccess: (response)=>
    @modal.find('.wrapper').html(response)

    setTimeout(
      ()->
        FR2.Modal.closeModal('#fr_modal')
      2500
    )

  submitFailure: (response)=>
    @modal.find('.wrapper').html(response.responseText)
