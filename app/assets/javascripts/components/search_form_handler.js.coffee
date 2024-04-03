class @FR2.SearchFormHandler
  constructor: (@searchForm)->
    @searchCount = new FR2.SearchFormCount(@searchForm)
    @agencyAutocompleter = new FR2.SearchFormAgencyAutocompleter(@searchForm)

    @addEvents()
    @setup()

  addEvents: ->
    $('#conditions_type_presdocu')
      .bind('click', @togglePresidentialDocumentTypes)

    # Ensure we trigger a full-page refresh of the search page when clicking on "Advanced Search" from the "Document Search" page
    $(".advanced-search")
      .bind('click', @_triggerAdvancedSearchFullPageRefresh)

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

  _triggerAdvancedSearchFullPageRefresh: (event) ->
    window.location.href = "/documents/search#advanced"
    window.location.reload()

  toggleAdvancedSearch: =>
    currentlyOpen = location.hash == "#advanced"

    if currentlyOpen
      @closeAdvancedSearch()
    else
      if !this.sentTrackingEvent
        this.sentTrackingEvent = true
        FR2.Analytics.trackToggleAdvancedSearch()
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
    $("#toggle_advanced").text("Hide Additional Filters")
    @calculateExpectedResults()

  closeAdvancedSearch: ->
    $(".advanced").removeClass("open")
    window.location.hash = ""
    $("#toggle_advanced").text("More Filters")
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
