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

  sortByAttr: (dataAttr, numerical)->
    return (a, b) ->
      aText = if $(a).data(dataAttr) then $(a).data(dataAttr) else $(a).text()
      bText = if $(b).data(dataAttr) then $(b).data(dataAttr) else $(b).text()

      if numerical
        parseInt(aText, 10) - parseInt(bText, 10)
      else
        (aText > bText) ? 1 : ((bText > aText) ? -1 : 0)

  addAlphaSorter: ()->
    @alphaSorter = $('.list-item-sorter.alphabetical-sorter')
    listItemSorter = this

    items = @itemList.find('> li')

    @alphaSorter.on 'click', 'li', (event)=>
      event.preventDefault()

      li = $(event.target).closest('li')
      el = li.find 'a'

      sortDirection = el.data('sort-direction')

      listItemSorter.alphaSorter.find('li').removeClass('on')
      li.addClass('on')

      sortedItems = items.toArray().toSorted(@sortByAttr('sorter-text'))

      if sortDirection == 'asc'
        listItemSorter.itemList.html sortedItems
      else if sortDirection == 'desc'
        listItemSorter.itemList.html sortedItems.reverse()

      listItemSorter.notifySorterUpdate('alphabetical')

  addCountSorter: ()->
    @countSorter = $('.list-item-sorter.count-sorter')
    listItemSorter = this

    items = @itemList.find('> li')

    @countSorter.on 'click', 'li', (event)=>
      event.preventDefault()

      li = $(event.target).closest('li')
      el = li.find 'a'

      sortDirection = el.data('sort-direction')

      listItemSorter.countSorter.find('li').removeClass('on')
      li.addClass('on')

      sortedItems = items.toArray().toSorted(@sortByAttr('sorter-count', true))

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
