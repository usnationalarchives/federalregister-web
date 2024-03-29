class @FR2.SearchCount
  constructor: (@type) ->
    @searchCountStore.init()

  searchCountStore: {
    init: ->
      if amplify.store('searchCount') == undefined
        amplify.store('searchCount', {})

    get: (url)->
      @init() # After 5 minutes occur, if a get() is re-attempted the 'searchCount' key no longer appears to exist', make sure the hash key is re-initialized accordingly
      amplify.store('searchCount')[url]

    set: (url, value)->
      val = _.extend(
        amplify.store('searchCount'),
        {"#{url}": value}
      )

      # expires in 10 minutes
      amplify.store('searchCount', val, {expires: 300000})
  }

  currentRequest: null

  countUrl: (params)->
    return "/#{@type}/search/count?#{params}"

  count: (params) =>
    @deferred = $.Deferred()
    url = @countUrl(params)

    # don't fetch a url already in the queue
    if @searchCountStore.get(url) == undefined

      searchCount = this
      @currentRequest = url

      $.ajax(url)
        .done (data)->
          searchCount.searchCountSuccess(url, data)
    else
      @returnResponse @searchCountStore.get(url)

    @deferred.promise()

  searchCountSuccess: (url, data)=>
    @searchCountStore.set(url, data)

    if @currentRequest == url
      @currentRequest == null
      @returnResponse(data)

  returnResponse: (data)->
    @deferred.resolve data
