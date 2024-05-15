class @FR2.Analytics
  @trackCommentEvent: (category, agency, documentNumber)=>
    @trackGAEvent category, agency, documentNumber

  @trackGAEvent: (category, action, label)->
    gtag('event', category, {'event_action': action, 'event_label': label})

  @trackSearchPageVisit: ->
    term = new URLSearchParams(window.location.search).get('conditions[term]')
    suggestionsCount = $('#search-results .suggestion:not(.ga-exclude)').length
    paginationPage = new URLSearchParams(window.location.search).get('page')

    gtag('event', 'search_page_visit', {
      'term':          term,
      'agencies':      this._getQueryParamArray('conditions[agencies][]'),
      'document_type': this._getQueryParamArray('conditions[type][]'),
      'pagination_page': paginationPage,
      'logged_in':     FR2.UserUtils.loggedIn(),
      'suggestions_count': suggestionsCount
    })

  @trackSearchResultClickThroughs: ->
    context = this

    $('a[data-search-result-position]').on 'click', (e) ->
      e.preventDefault()
      term = new URLSearchParams(window.location.search).get('conditions[term]')
      suggestionsCount = $('#search-results .suggestion:not(.ga-exclude)').length
      paginationPage = new URLSearchParams(window.location.search).get('page')

      searchResultPosition = $(this).data('search-result-position')
      gtag('event', 'search_page_click_through', {
        'term':          term,
        'agencies':      context._getQueryParamArray('conditions[agencies][]'),
        'document_type': context._getQueryParamArray('conditions[type][]'),
        'pagination_page': paginationPage,
        'logged_in':     FR2.UserUtils.loggedIn(),
        'suggestions_count': suggestionsCount,
        'search_result_position': searchResultPosition,
        'search_result_position_dimension': searchResultPosition,
      })
      window.location.href = $(this).attr('href')

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
