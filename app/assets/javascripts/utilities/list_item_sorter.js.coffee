class @FR2.ListItemSorter
  defaultOptions: ->
    {
      sorters: {
        alphabetical: true
        count: true
      }
    }

  constructor: (itemList, options)->
    @itemList = $(itemList)
    @settings =  Object.assign(@defaultOptions(), options || {})

    if @settings.sorters.alphabetical
      @addAlphaSorter()

    if @settings.sorters.count
      @addCountSorter()

  notifySorterUpdate: (skipSorter)->
    _.each @settings.sorters, (active, sorter)=>
      if sorter != skipSorter && active == true
        @resetSorter sorter

  resetSorter: (sorter)->
    switch sorter
      when 'alphabetical'
        @alphaSorter.find('li').removeClass('on')
      when 'count'
        @countSorter.find('li').removeClass('on')

  addAlphaSorter: ()->
    @alphaSorter = $('.list-item-sorter.alphabetical-sorter')
    listItemSorter = this

    items = @itemList.find('> li')

    @alphaSorter.on 'click', 'li', (event)->
      event.preventDefault()

      li = $(this)
      el = li.find 'a'

      sortDirection = el.data('sort-direction')

      listItemSorter.alphaSorter.find('li').removeClass('on')
      li.addClass('on')

      sortedItems = _.sortBy items, (item)->
        item = $(item)
        return  if item.data('sorter-text') then item.data('sorter-text') else item.text()

      if sortDirection == 'asc'
        listItemSorter.itemList.html sortedItems
      else if sortDirection == 'desc'
        listItemSorter.itemList.html sortedItems.reverse()

      listItemSorter.notifySorterUpdate('alphabetical')

  addCountSorter: ()->
    @countSorter = $('.list-item-sorter.count-sorter')
    listItemSorter = this

    items = @itemList.find('> li')

    @countSorter.on 'click', 'li', (event)->
      event.preventDefault()

      li = $(this)
      el = li.find 'a'

      sortDirection = el.data('sort-direction')

      listItemSorter.countSorter.find('li').removeClass('on')
      li.addClass('on')

      sortedItems = _.sortBy items, (item)->
        item = $(item)
        return  if item.data('sorter-count') then item.data('sorter-count') else item.text()

      if sortDirection == 'asc'
        listItemSorter.itemList.html sortedItems
      else if sortDirection == 'desc'
        listItemSorter.itemList.html sortedItems.reverse()

      listItemSorter.notifySorterUpdate('count')

class @FR2.TopicListSorter extends @FR2.ListItemSorter
  constructor: (itemList, options)->
    super itemList, options

class @FR2.AgencyListSorter extends @FR2.ListItemSorter
  constructor: (itemList, options)->
    super itemList, options
