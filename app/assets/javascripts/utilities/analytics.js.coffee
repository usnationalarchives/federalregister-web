class @FR2.Analytics
  @trackCommentEvent: (category, agency, documentNumber) =>
    @trackGAEvent category, agency, documentNumber

  @trackGAEvent: (category, action, label, value) ->
    data = {'event_action': action, 'event_label': label}

    # optional - used by some events
    if value
      data['value'] = value

    gtag('event', category, data)

  @trackOmniSearchInputInteraction: ->
    gtag('event', 'omni_search_input_interaction', {
      'logged_in':     FR2.UserUtils.loggedIn(),
    })

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


  ###########################################################################
  # Clippings
  ###########################################################################

  @trackClippingEvent: (action, document_number, folder_slug) =>
    # current actions: add, remove
    user_state  = @_userState()
    page_type = @_pageType()
    folder_type = @_folderType(folder_slug)

    label = "#{user_state}/#{folder_type}/#{page_type}/#{document_number}"

    @trackGAEvent("Clipping", action, label)

  @trackFolderEvent: (action, document_count) =>
    # current actions: create

    user_state  = @_userState()
    page_type = @_pageType()
    folder_type = "folder"

    label = "#{user_state}/#{folder_type}/#{page_type}"

    @trackGAEvent("Folder", action, label, document_count)

  @_userState: ->
    if FR2.UserUtils.loggedIn()
      'logged_in'
    else
      'logged_out'

  @_pageType: ->
    if window.location.pathname.match(/\/search/) == null
      'document'
    else
      'search'

  @_folderType: (folder_slug)->
    if folder_slug == 'my-clippings'
      'clipboard'
    else
      'folder'

  ###########################################################################
  # Navigation
  ###########################################################################

  @trackMyFR2NavigationEvent: (value)->
    @trackGAEvent("Navigation", "Navigation", "MyFR", value)
