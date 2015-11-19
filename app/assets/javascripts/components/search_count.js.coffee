class @FR2.SearchCount
  constructor: (@searchForm)->
    @requests = {}

    @addEvents()

  cache: ->
    @searchForm.data('count_cache') || {}

  setCache: (url, data) ->
    cache = @cache()
    cache[url] = data
    @searchForm.data('count_cache', cache)

  checkCache: (url) ->
    @cache()[url]

  populateExpectedResults: (obj)->
    if obj.count == 1
      text = "#{obj.count} document"
    else
      text = "#{obj.count} documents"

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

  apiUrl: ->
    if @searchForm.attr('id').match('entry')
      url = '/api/v1/documents.json'
    else if @searchForm.attr('id').match('public_inspection')
      url = '/api/v1/public-inspection-documents.json'

    params = @searchForm
      .find(":input[value!='']:not([data-show-field]):not('.text-placeholder')")
      .serialize()

    if params
      params += "&metadata_only=1"
    else
      params = "metadata_only=1"

    return "#{url}?#{params}"

  calculateExpectedResults: =>
    searchCount = this
    url = @apiUrl()

    # check the cache for this url
    if @checkCache(url) == undefined
      # record that this is the current result we're waiting for
      @searchForm.data('count_current_url', url)

      @indicateLoading()

      # don't fetch a url already in the queue
      if @requests[url] == undefined
        @requests[url] = url

        $.ajax(url)
          .done (data)->
            searchCount.calculateExpectedResultsSuccess(url, data)
    else
      @populateExpectedResults @checkCache(url)

  calculateExpectedResultsSuccess: (url, data)->
    @requests[url] == undefined
    @setCache(url, data)

    # populate the results if this is the pending request
    if @searchForm.data('count_current_url') == url
      @populateExpectedResults @checkCache(url)

  addEvents: ->
    searchCount = this

    @searchForm
      .find 'select, input'
      .bind 'blur', (event)->
        searchCount.calculateExpectedResults()

    @searchForm
      .find 'input[type=checkbox]'
      .bind 'click', (event)->
        searchCount.calculateExpectedResults()

    @searchForm
      .find '#conditions_agency_ids'
      .bind 'change', (event)->
        searchCount.calculateExpectedResults()

    @addTypewatch()

  addTypewatch: ->
    options = {
      callback: @calculateExpectedResults,
      wait: 350,
      captureLength: 3
    }

    @searchForm
      .find 'input[type=text]'
      .typeWatch options
