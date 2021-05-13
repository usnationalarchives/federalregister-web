class @FR2.ZendeskFormHandler

  constructor: ->
    this.bindHandlers()

  bindHandlers: ->
    context = this
    $('.zendesk_ticket button').on(
      'click',
      (e) =>
        e.preventDefault()
        context.submitForm()
    )

  submitForm: ->
    if this._formPassesPrevalidation()
      form = $('form.zendesk_ticket')

      $.ajax({
        url: '/zendesk_tickets',
        type: 'POST',
        data: JSON.stringify({
          "attributes": form.serialize(),
          "type":"comments"
        })
      }).done (results) =>
        console.log(results)
    else
      this._highlightLabelsForMissingFields()

  _formPassesPrevalidation: () ->
    _.all(this._requiredFields(), (el) ->
      $(el).val() != ""
    )

  _requiredFields: () ->
    #TODO: Handle boolean required flag
    $('form.zendesk_ticket input')

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

