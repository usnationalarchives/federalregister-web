class @FR2.ListItemFilter
  defaultOptions: ->
    {
      filters: {
        alphabetical: true
        liveFilter: true
      }
    }

  constructor: (itemList, options)->
    @itemList = $(itemList)
    @settings = _.extend(@defaultOptions(), options || {})

    if @settings.filters.alphabetical
      @addAlphaFilter()

    if @settings.filters.liveFilter
      @addLiveFilter()

  notifyFilterReset: (skipFilter)->
    _.each @settings.filters, (active, filter)=>
      if filter != skipFilter && active == true
        @resetFilter filter

  resetFilter: (filter)->
    switch filter
      when 'alphabetical'
        @alphaFilter.find('li').removeClass('on')
      when 'liveFilter'
        @liveFilter.find('input').val('')

  addAlphaFilter: ()->
    @alphaFilter = $('.list-item-filter.alphabetical') # set filter for later use
    listItemFilter = this

    items = @itemList.find('> li')

    @alphaFilter.on 'click', 'li a', (event)->
      event.preventDefault()
      listItemFilter.notifyFilterReset('alphabetical')

      el = $(this)

      listItemFilter.alphaFilter.find('li').removeClass('on')
      el.closest('li').addClass('on')

      if el.data('regex') == 'all'
        items.show()
      else
        matchingItems = _.filter items, (item)->
           return $(item).data('filter-alpha').match(new RegExp(el.data('filter-regex')))

        items.hide()
        $(matchingItems).show()

  addLiveFilter: ()->
    @liveFilter = $('.live-filter')
    input = @liveFilter.find('input')

    input.val('')

    input.on 'keyup', (event)=>
      @notifyFilterReset('liveFilter')

      items = @itemList.find('> li')

      if input.val() == ''
        items.show()
      else
        matchingItems = _.filter items, (item)->
           return $(item).data('filter-live').match(new RegExp("\\b#{input.val()}", 'i'))

        items.hide()
        $(matchingItems).show()


class @FR2.TopicListFilter extends @FR2.ListItemFilter
  constructor: (itemList, options)->
    super itemList, options

class @FR2.AgencyListFilter extends @FR2.ListItemFilter
  constructor: (itemList, options)->
    super itemList, options
