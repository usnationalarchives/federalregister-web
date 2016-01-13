$(document).ready ()->
  new FR2.HomeSectionPreviewManager('.home-section-preview')

  _.each $('#main form.facet-explorer-search'), (form)->
    new FR2.Autocompleter $(form)
