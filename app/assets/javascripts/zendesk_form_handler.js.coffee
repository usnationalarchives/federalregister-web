class @FR2.ZendeskFormHandler

  constructor: ->
    this._displayForm()
    this.bindHandlers()

  bindHandlers: ->
    context = this
    this._bindModalCloseHandler()
    $('.zendesk_ticket button').on(
      'click',
      (e) ->
        e.preventDefault()
        context.submitForm()
    )

  submitForm: ->
    context = this
    if this._formPassesPrevalidation()
      $.ajax({
        contentType: false,
        processData: false,
        url: '/zendesk_tickets',
        type: 'POST',
        data: this._formData(),
        success: () ->
          context._displaySuccessMessage()
        error: (xhr, status, error) ->
          Honeybadger.notify(
            "Failure to submit zendesk comment",
            {context: {
              status: xhr.status,
              errors: xhr.responseJSON
            }}
          )
          alert("We're sorry, an error occurred when trying to submit your request, we've been notified and will be looking into it.")
      })
    else
      this._highlightLabelsForMissingFields()

  _displayForm: ->
    if !$('#interstitial_tender_modal').is(":visible") # eg the user is on a non-document page
      this._initializeModal()

    zendeskTemplate = $('#zendesk-feedback-modal-template')
    compiled = Handlebars.compile( zendeskTemplate.html() )
    $('.tender_interstitial_modal').html(compiled({}))

  _initializeModal: ->
    interstitial_tender_modal_template = $('#interstitial-tender-modal-template')
    interstitial_tender_modal_template = Handlebars.compile( interstitial_tender_modal_template.html() )
    FR2.Modal.displayModal(
      '',
      interstitial_tender_modal_template({
        document_feedback_text: '',
        document_button_enabled: false
      }),
      {
        modalId: '#interstitial_tender_modal',
        includeTitle: false,
        modalClass: 'fr_modal wide'
      }
    )

  _displaySuccessMessage: ->
    template = $('#feedback-success-template')
    compiled = Handlebars.compile( template.html() )
    $('form.zendesk_ticket').remove()
    $('#interstitial_tender_modal h3').after(compiled({}))

  _formData: ->
    form = $('form.zendesk_ticket')
    formData = new FormData form[0]
    formData.append('browser_metadata', this._browserMetadata())
    formData

  _browserMetadata: ->
    metadata = _.pick(bowser, 'name', 'version','osname', 'osversion', 'blink')
    metadata.project = 'FR'
    JSON.stringify(metadata)

  _bindModalCloseHandler: () ->
    # The JQM overlay remains if the close button is selected.  Override the close handler so it's removed.
    $('.jqmClose').on(
      'click',
      () ->
        $('.jqmOverlay').remove()
    )

  _formPassesPrevalidation: () ->
    _.all(this._requiredFields(), (el) ->
      $(el).val() != ""
    )

  _requiredFields: () ->
    $("form.zendesk_ticket input, form.zendesk_ticket textarea, #zendesk_ticket_technical_help").not(":hidden").not(":file")

  _highlightLabelsForMissingFields: ->
    # Clear red for all labels
    $.each(this._requiredFields(), () ->
      $(this).siblings('label').removeClass('required-error')
    )

    # Apply red to missing required fields
    blankRequiredFields = _.filter(this._requiredFields(), (el) -> $(el).val() == '' )
    $.each(blankRequiredFields, () ->
      $(this).siblings('label').addClass('required-error')
    )

    # Handle checkbox since it's not handled the same as an iput
    if $("#zendesk_ticket_technical_help").is(':checked')
      $("#zendesk_ticket_technical_help").parent('label').removeClass('required-error')
    else
      $("#zendesk_ticket_technical_help").parent('label').addClass('required-error')


