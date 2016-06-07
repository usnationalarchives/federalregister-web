class @FR2.SearchTabCount
  constructor: (@searchForm, @searchTab)->
    @searchCount = new FR2.SearchCount(@searchTabType())
    @linkEl = $(@searchTab).find('a')
    @resultEl = $(@searchTab).find('.number_of_results')
    @addEvents()

  searchTabType: ->
    if @searchTab.hasClass('documents')
      'documents'
    else if @searchTab.hasClass('public-inspection')
      'public-inspection'

  populateExpectedResults: (obj)->
    @linkEl.attr('href', obj.url)
    @resultEl.html(obj.count)

  indicateLoading: ->
    @resultEl.html("<div class='loader'></div>")

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
