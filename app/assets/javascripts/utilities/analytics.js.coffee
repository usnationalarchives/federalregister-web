class @FR2.Analytics
  @trackCommentEvent: (category, agency, documentNumber)=>
    @trackGAEvent category, agency, documentNumber

  @trackGAEvent: (category, action, label)->
    gtag('event', category, {'event_action': action, 'event_label': label})

  @trackSearchPageVisit: ->
    term = new URLSearchParams(window.location.search).get('conditions[term]')
    suggestionsCount = $('#search-results .suggestion:not(.ga-exclude)').length

    gtag('event', 'search_page_visit', {
      'term':          term,
      'agencies':      this._getQueryParamArray('conditions[agencies][]'),
      'document_type': this._getQueryParamArray('conditions[type][]'),
      'logged_in':     FR2.UserUtils.loggedIn(),
      'suggestions_count': suggestionsCount
    })

  @trackToggleAdvancedSearch: ->
    term = new URLSearchParams(window.location.search).get('conditions[term]')
    gtag('event', 'toggle_advanced_search', {
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
