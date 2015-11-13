# This file is loaded only by search pages
#= require old/search.js

$(document).ready ()->
  if $('#entry_search_form').length > 0
    searchForm = $('#entry_search_form')
  else if $('#public_inspection_search_form').length > 0
    searchForm = $('#public_inspection_search_form')

  new FR2.SearchFormHandler(searchForm)
