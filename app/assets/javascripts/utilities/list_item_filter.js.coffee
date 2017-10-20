class @FR2.ListItemFilter
  defaultOptions: ->
    {
      filters: {
        alphabetical: true
        liveFilter: true
      },
      filterCountTarget: null
      nestedItems: false
    }

  constructor: (itemList, options)->
    @itemList = $(itemList)
    @settings = _.extend(@defaultOptions(), options || {})

    if @settings.filters.alphabetical
      @addAlphaFilter()

    if @settings.filters.liveFilter
      @addLiveFilter()

  notifyFilterUpdate: (triggeringFilter)->
    _.each @settings.filters, (active, filter)=>
      if filter != triggeringFilter && active == true
        @resetFilter filter, triggeringFilter

    @updateFilterCount()

  resetFilter: (filter, triggeringFilter)->
    switch filter
      when 'alphabetical'
        @alphaFilter.find('li').removeClass('on')

        if @liveFilter.find('input').val() == ''
          @alphaFilter
            .find 'li'
            .first()
            .addClass 'on'

      when 'liveFilter'
        @liveFilter
          .find 'input'
          .val('')

        @itemList
          .find 'li[data-filter-alpha]'
          .removeClass 'unmatched'

  addAlphaFilter: ()->
    @alphaFilter = $('.list-item-filter.alphabetical-filter') # set filter for later use
    listItemFilter = this

    items = @itemList.find('li[data-filter-alpha]')

    @alphaFilter.on 'click', 'li', (event)->
      event.preventDefault()

      li = $(this)
      el = li.find 'a'

      listItemFilter.alphaFilter.find('li').removeClass('on')
      li.addClass('on')

      if el.data('regex') == 'all'
        items.show()
      else
        matchingItems = _.filter items, (item)->
          return $(item).data('filter-alpha').match(new RegExp(el.data('filter-regex')))

        items.hide()
        $(matchingItems).show()

      listItemFilter.notifyFilterUpdate('alphabetical')

  addLiveFilter: ()->
    @liveFilter = $('.list-item-filter.live-filter')
    input = @liveFilter.find('input')

    input.val('')

    input.on 'keyup', (event)=>
      items = @itemList.find('li[data-filter-live]')

      if input.val() == ''
        items.show()
        @notifyFilterUpdate()
      else
        matchingItems = _.filter items, (item)->
          return $(item).data('filter-live').match(new RegExp("\\b#{input.val()}", 'i'))

        items.hide().removeClass('unmatched')

        if @settings.nestedItems
          _.each matchingItems, (item)->
            item = $(item)
            item.show()
            item
              .parents 'li[data-filter-live]'
              .show()
              .addClass 'unmatched'
        else
          $(matchingItems).show()

      @notifyFilterUpdate('liveFilter')

  updateFilterCount: ()->
    if @settings.filterCountTarget
      $(@settings.filterCountTarget)
        .html @itemList.find('li:visible:not(".unmatched")').size()


class @FR2.TopicListFilter extends @FR2.ListItemFilter
  defaultOptions: ->
    topicDefaults = {
      filterCountTarget: '#item-count'
    }

    _.extend super(), topicDefaults

  constructor: (itemList, options)->
    super itemList, options


class @FR2.AgencyListFilter extends @FR2.ListItemFilter
  defaultOptions: ->
    agencyDefaults = {
      filters: {
        alphabetical: true
        liveFilter: true
        subAgencies: true
      },
      filterCountTarget: '#item-count',
      nestedItems: true
    }

    _.extend super(), agencyDefaults

  constructor: (itemList, options)->
    super itemList, options

    if @settings.filters.subAgencies
      @addSubAgencyFilter()

  resetFilter: (filter, triggeringFilter)->
    switch filter
      when 'subAgencies'
        # maintain current setting when alphabetical by triggering ourselves
        # after the alphabetical filter
        if triggeringFilter == 'alphabetical'
          $('.list-item-filter.sub-agency-filter li.on')
            .trigger 'click'
        else
          # just reset the classes as the triggering filter is correctly
          # handling what to show
          $('.list-item-filter.sub-agency-filter li')
            .removeClass 'on'
          $('.list-item-filter.sub-agency-filter a[data-show-sub-agencies=true]')
            .closest 'li'
            .addClass 'on'

      else
        super filter

  addSubAgencyFilter: ()->
    @subAgencyFilter = $('.list-item-filter.sub-agency-filter')
    listItemFilter = this

    items = @itemList.find('li[data-sub-agency]')

    @subAgencyFilter.on 'click', 'li', (event)->
      event.preventDefault()

      li = $(this)
      el = li.find 'a'

      showChildAgencies = el.data('show-sub-agencies')

      listItemFilter.subAgencyFilter.find('li').removeClass('on')
      li.addClass('on')

      if showChildAgencies
        items.show()
      else
        items.hide()
