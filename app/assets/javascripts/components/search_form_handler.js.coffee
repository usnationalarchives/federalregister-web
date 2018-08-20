class @FR2.SearchFormHandler
  constructor: (@searchForm)->
    @searchCount = new FR2.SearchFormCount(@searchForm)
    @agencyAutocompleter = new FR2.SearchFormAgencyAutocompleter(@searchForm)

    @addEvents()
    @setup()

  addEvents: ->
    $('#conditions_type_presdocu')
      .bind('click', @togglePresidentialDocumentTypes)

    $('.clear_form')
      .bind('click', @clearForm)

    $("#toggle_advanced")
      .bind('click', @toggleAdvancedSearch)

    $("input[data-show-field]")
      .bind('change', @inputDataShowFieldChange)

  setup: ->
    @togglePresidentialDocumentTypes()
    @initializeAdvancedSearch()

    $(".date_options .date").hide()
    $(".date_options input[data-show-field]:checked")
      .trigger "change"

    _.each $("input[data-show-field]"), @intializeInputDataShowFields

    @addHelperText()

  togglePresidentialDocumentTypes: ->
    typeCheckboxes = $('.presidential_dependent')

    if $('#conditions_type_presdocu').prop('checked')
      typeCheckboxes
        .show()
        .find(':input')
        .removeAttr('disabled')
    else
      typeCheckboxes
        .hide()
        .find(':input')
        .prop('disabled', 'disabled')

  clearForm: (event)=>
    event.preventDefault()

    @searchForm
      .find('input[type=text],input[type=hidden]')
      .val('')

    @searchForm
      .find('input[type=radio],input[type=checkbox]')
      .removeAttr('checked')
      .change()

    @searchForm
      .find('select option:eq(0)')
      .prop('selected','selected')

    @searchForm
      .find('#conditions_agency_ids option')
      .remove()

    @searchForm
      .find('#conditions_within option:eq(3)')
      .prop('selected','selected')

    @searchForm
      .find('.bsmListItem')
      .remove()

    @searchForm
      .find('.date')
      .hide()
      .find("input")
      .val('')

    @calculateExpectedResults()

  toggleAdvancedSearch: =>
    currentlyOpen = location.hash == "#advanced"

    if currentlyOpen
      @closeAdvancedSearch()
    else
      @openAdvancedSearch()

  initializeAdvancedSearch: =>
    shouldOpen = location.hash == "#advanced"

    if shouldOpen
      @openAdvancedSearch()
    else
      @closeAdvancedSearch()

  openAdvancedSearch: ->
    $(".advanced").addClass("open")
    window.location.hash = "#advanced"
    $("#toggle_advanced").text("Hide Advanced Search")
    @calculateExpectedResults()

  closeAdvancedSearch: ->
    $(".advanced").removeClass("open")
    window.location.hash = ""
    $("#toggle_advanced").text("Show Advanced Search")
    @calculateExpectedResults()
    false #return false or the hash will reset improperly

  inputDataShowFieldChange: (event)=>
    input = $(event.currentTarget)
    parentFieldset = input.closest("fieldset")

    parentFieldset
      .find(".date")
      .hide()
      .find(":input")
      .prop('disabled', true)

    if input.prop('checked')
      parentFieldset
        .find(".#{input.attr('data-show-field')}")
        .show()
        .find(":input")
        .prop('disabled', false)

    @calculateExpectedResults()

  intializeInputDataShowFields: (input)->
    input = $(input)

    parentFieldset = input.closest("fieldset")
    matchingInputs = parentFieldset
      .find(".#{input.attr("data-show-field")} :input")

    _.each matchingInputs, (matchingInput)->
      if $(matchingInput).val() != '' && !$(matchingInput).hasClass('text-placeholder')
        input.prop('checked', true)
        input.change()

  addHelperText: ->
    # add in some text to make certain form fields more
    # clear for the user - but that aren't easily put on
    # the form via the form builder when creating the html
    @searchForm
      .find(".range_start input")
      .after("<span class='input-connector'> to </span>")

    @searchForm
      .find(".cfr li:first-child input")
      .after("<span class='input-connector'> CFR </span>")

    @searchForm
      .find(".zip li:first-child input")
      .after("<span class='input-connector'> within </span>")

  calculateExpectedResults: ->
    @searchCount.getResultCount()
