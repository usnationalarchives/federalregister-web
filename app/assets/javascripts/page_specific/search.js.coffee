$(document).ready ()->
  pagers = $('.search .result-set .pagination')

  _.each pagers, (pager) ->
    $(pager)
      .css 'width', $(pager).width() + 5
      .css 'display', 'block'
