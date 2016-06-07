class @FR2.SearchFormCount
  constructor: (@searchForm)->
    @searchCount = new FR2.SearchCount(@searchFormType())
    @addEvents()

  searchFormType: ->
    if @searchForm.hasClass('documents')
      'documents'
    else if @searchForm.hasClass('public-inspection')
      'public-inspection'

  populateExpectedResults: (obj)->
    formattedCount = numeral(obj.count).format('0,0')
    if formattedCount == "1"
      text = "#{formattedCount} document"
    else
      text = "#{formattedCount} documents"

    $('#expected_result_count')
      .find '.loader'
      .hide()

    $('#expected_result_count')
      .find '.document-count'
      .text text
      .show()

  indicateLoading: ->
    $('#expected_result_count')
      .show()

    $('#expected_result_count')
      .find '.document-count'
      .hide()

    $('#expected_result_count')
      .find '.loader'
      .show()

  getResultCount: =>
    params = @searchForm
      .find(":input[value!='']:not([data-show-field]):not('.text-placeholder')")
      .serialize()

    @indicateLoading()
    @searchCount.count(params)
      .then (response)=>
        @populateExpectedResults response

  addEvents: ->
    searchCount = this

    @searchForm
      .find 'select, input'
      .bind 'blur', (event)->
        searchCount.getResultCount()

    @searchForm
      .find 'input[type=radio]'
      .bind 'change', (event)->
        searchCount.getResultCount()

    @searchForm
      .find 'input[type=checkbox]'
      .bind 'change', (event)->
        searchCount.getResultCount()

    @searchForm
      .find '#conditions_agencies'
      .bind 'change', (event)->
        searchCount.getResultCount()

    @addTypewatch()

  addTypewatch: ->
    options = {
      callback: @getResultCount,
      wait: 350,
      captureLength: 3
    }

    @searchForm
      .find 'input[type=text]'
      .typeWatch options
