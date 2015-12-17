class @FR2.EmbeddedSearch
  constructor: (@searchForm)->
    @doctypeFilters = @searchForm.find('#doc-type-filter li')
    @searchCount = new FR2.SearchCount(@searchForm)

    @setupTooltips()
    @addTooltips()
    @addMouseEvents()
    @calculateExpectedResults()

  setupTooltips: ->
    _.each @doctypeFilters, (filter)->
      filter = $(filter)
      type = filter.data('filter-doc-type-display')

      filter.data(
        'tooltip',
        "Limit search to documents of type #{type}"
      )

  # only add tooltips to items that are active
  addTooltips: ->
    @doctypeFilters.filter(':not(.disabled)').tipsy({
      gravity: 'n'
      fade: false
      offset: 2
      title: ->
        $(this).data('tooltip')
    })

  addMouseEvents: ->
    embeddedSearch = this
    filterWrapper = @searchForm.find('#doc-type-filter')

    filterWrapper.on 'mouseenter', 'li', ->
      $(this).addClass('hover')

    filterWrapper.on 'mouseleave', 'li', ->
      $(this).removeClass('hover')

    filterWrapper.off 'click'
    filterWrapper.on 'click', 'li', (evt)->
      embeddedSearch.setFilterState $(this)

  calculateExpectedResults: ->
    @searchCount.calculateExpectedResults()

  setFilterState: (filterEl)->
    if filterEl.hasClass('on')
      @triggerFilterOffState(filterEl)
    else
      @triggerFilterOnState(filterEl)

  triggerFilterOffState: (filterEl)->
    # remove on state
    filterEl
      .removeClass 'on'
      .removeClass 'hover'

    # change tooltip
    filterEl.data(
      'tooltip',
      "Limit search to documents of type #{filterEl.data('filter-doc-type-display')}"
    )

    # toggle state so new tooltip is showing
    filterEl
      .tipsy('hide')
      .tipsy('show')

    # update hidden checkboxes and recalculate result counts
    @searchForm
      .find "#conditions_type_input input#conditions_type_#{filterEl.data('filter-doc-type')}"
      .prop 'checked', false

    @calculateExpectedResults()

  triggerFilterOnState: (filterEl)->
    # add on state
    filterEl.addClass 'on'

    # change tooltip
    filterEl.data(
      'tooltip',
      "Remove limitation (documents of type #{filterEl.data('filter-doc-type-display')})"
    )

    # toggle state so new tooltip is showing
    filterEl
      .tipsy('hide')
      .tipsy('show')

    # update hidden checkboxes and recalculate result counts
    @searchForm
      .find "#conditions_type_input input#conditions_type_#{filterEl.data('filter-doc-type')}"
      .prop 'checked', true

    @calculateExpectedResults()
