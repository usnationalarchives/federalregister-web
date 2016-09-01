class @FR2.SubscriptionFilter
  constructor: (actionBar, subscriptionTypeFilters)->
    @actionBar = $(actionBar)
    @subscriptionTypeFilters = subscriptionTypeFilters

    @init()
    @addEvents()

  init: ->
    _.each $('.subscription-type-filter li'), (filter)->
      if _.include(subscriptionTypeFilters, $(filter).data('filter-doc-type'))
        $(filter).addClass('on')
        $(filter).data('tooltip', 'Hide ' + $(filter).data('filter-doc-type-display') + ' subscriptions' )
      else
        $(filter).addClass('disabled')

  addEvents: ->
    subscriptionFilter = this
    filter = @actionBar.find('.subscription-type-filter')

    filter.on 'mouseenter', 'li:not(.disabled)', (event)->
      $(this).addClass('hover')

    filter.on 'mouseleave', 'li:not(.disabled)', (event)->
      $(this).removeClass('hover')

    filter.on 'click', 'li:not(.disabled)', (event)->
      subscriptionFilter.filterSubscriptionsByType $(this)

    filter.find('li:not(.disabled)').tipsy({
      gravity: 's'
      fade: true
      offset: 2
      title: ->
        $(this).data('tooltip')
    })

  filterSubscriptionsByType: (el)->
    docType = el.data('filter-doc-type')

    if el.hasClass('on')
      @filterOff(el)
    else
      @filterOn(el)

    @toggleSubscriptions(docType)

  filterOn: (el)->
    el.addClass('on')

    el.data('tooltip', 'Hide ' + el.data('filter-doc-type-display') + ' subscriptions')
    el.tipsy('hide')
    el.tipsy('show')

  filterOff: (el)->
    el.removeClass('on')
    el.removeClass('hover')

    el.data('tooltip', 'Show ' + el.data('filter-doc-type-display') + ' subscriptions')
    el.tipsy('hide')
    el.tipsy('show')

  toggleSubscriptions: (docType)->
    subscriptionsToToggle = _.filter $('.subscriptions li'), (subscription)->
      return docType == $(subscription).data('doc-type')

    $(subscriptionsToToggle).toggle()
