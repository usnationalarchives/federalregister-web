class @FR2.ListItemFilter
  defaultOptions: ->
    {
      filters: {
        alphabetical: true
        liveFilter: true
      },
      filterCountTarget: null
    }

  constructor: (itemList, options)->
    @itemList = $(itemList)
    @settings = _.extend(@defaultOptions(), options || {})

    if @settings.filters.alphabetical
      @addAlphaFilter()

    if @settings.filters.liveFilter
      @addLiveFilter()

  notifyFilterUpdate: (skipFilter)->
    _.each @settings.filters, (active, filter)=>
      if filter != skipFilter && active == true
        @resetFilter filter

    @updateFilterCount()

  resetFilter: (filter)->
    switch filter
      when 'alphabetical'
        @alphaFilter.find('li').removeClass('on')

        if @liveFilter.find('input').val() == ''
          @alphaFilter
            .find 'li'
            .first()
            .addClass 'on'

      when 'liveFilter'
        @liveFilter.find('input').val('')

  addAlphaFilter: ()->
    @alphaFilter = $('.list-item-filter.alphabetical-filter') # set filter for later use
    listItemFilter = this

    items = @itemList.find('> li')

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
      items = @itemList.find('> li')

      if input.val() == ''
        items.show()
      else
        matchingItems = _.filter items, (item)->
           return $(item).data('filter-live').match(new RegExp("\\b#{input.val()}", 'i'))

        items.hide()
        $(matchingItems).show()

      @notifyFilterUpdate('liveFilter')

  updateFilterCount: ()->
    if @settings.filterCountTarget
      $(@settings.filterCountTarget)
        .html @itemList.find('> li:visible').size()


class @FR2.TopicListFilter extends @FR2.ListItemFilter
  constructor: (itemList, options)->
    super itemList, options

class @FR2.AgencyListFilter extends @FR2.ListItemFilter
  constructor: (itemList, options)->
    super itemList, options
