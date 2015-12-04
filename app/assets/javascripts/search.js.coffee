$(document).ready ()->
  if $('#embedded_entry_search_form').length > 0
    frSearch = new FR2.EmbeddedSearch $('#embedded_entry_search_form')
  else if $('#entry_search_form').length > 0
    frSearch = new FR2.SearchFormHandler $('#entry_search_form')
  else if $('#public_inspection_search_form').length > 0
    frSearch = new FR2.SearchFormHandler $('#public_inspection_search_form')

  frSearch.calculateExpectedResults()
