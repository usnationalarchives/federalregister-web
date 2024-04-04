class @FR2.Analytics
  @trackCommentEvent: (category, agency, documentNumber)=>
    @trackGAEvent category, agency, documentNumber

  @trackGAEvent: (category, action, label)->
    gtag('event', category, {'event_action': action, 'event_label': label})

  @trackSearchPageVisit: ->
    term = new URLSearchParams(window.location.search).get('conditions[term]')
    gtag('event', 'search_page_visit', {
      'debug_mode':    this._debugMode(),
      'term':          term,
      'agencies':      this._getQueryParamArray('conditions[agencies][]'),
      'document_type': this._getQueryParamArray('conditions[type][]'),
      'logged_in':     FR2.UserUtils.loggedIn()
    })

  @trackToggleAdvancedSearch: ->
    term = new URLSearchParams(window.location.search).get('conditions[term]')
    gtag('event', 'toggle_advanced_search', {
      'debug_mode':    this._debugMode(),
      'term':          term,
      'agencies':      this._getQueryParamArray('conditions[agencies][]'),
      'document_type': this._getQueryParamArray('conditions[type][]'),
      'logged_in':     FR2.UserUtils.loggedIn()
    })

  @_getQueryParamArray: (paramName) ->
    queryString = window.location.search.substring(1)
    params      = new URLSearchParams(queryString)
    paramValues = params.getAll(paramName)
    return paramValues

  @_debugMode: ->
    # Use this in development to toggle debug mode
    false
