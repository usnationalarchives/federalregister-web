class @FR2.SearchFacetHandler
  constructor: (facets)->
    _.each facets, (facet)->
      new CJ.ToggleOne(facet)
