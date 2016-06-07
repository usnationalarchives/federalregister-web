$(document).ready ()->
  if $('#embedded_entry_search_form').length > 0
    frSearch = new FR2.EmbeddedSearch $('#embedded_entry_search_form')
    searchCounts = []
  else if $('#entry_search_form').length > 0
    frSearch = new FR2.SearchFormHandler $('#entry_search_form')
    searchCounts = [new FR2.SearchTabCount($('#entry_search_form'), $('.tabs li.public-inspection'))]
  else if $('#public_inspection_search_form').length > 0
    frSearch = new FR2.SearchFormHandler $('#public_inspection_search_form')
    searchCounts = [new FR2.SearchTabCount($('#public_inspection_search_form'), $('.tabs li.documents'))]

  if frSearch
    frSearch.calculateExpectedResults()
    _.each searchCounts, (searchCount)->
      searchCount.getResultCount()
