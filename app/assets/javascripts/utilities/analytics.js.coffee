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
      'suggestions_count': suggestionsCount,
      'search_result_count': $('#item-count').text().trim().replace(/,/g, ''),
    })

  @trackPopularDocumentClickThroughs: ->
    context = this

    $('a[data-popular-document-position]').on 'click', (e) ->
      e.preventDefault()

      popularDocumentPosition = $(this).data('popular-document-position')
  
      gtag('event', 'popular_document_click_through', {
        'logged_in':     FR2.UserUtils.loggedIn(),
        'popular_document_position': popularDocumentPosition,
        'popular_document_position_dimension': popularDocumentPosition
      })
      window.location.href = $(this).attr('href')

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
        'search_result_count': $('#item-count').text().trim().replace(/,/g, ''),
      })

      url = $(this).attr('href')
      if (event.ctrlKey || event.metaKey || event.button == 1) # ie command-click
        window.open(url, '_blank')
      else
        window.location.href = url

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
