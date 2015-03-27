$(document).ready ->
  _.each $('.toggle'), (el)->
    link = $(el)
    trigger = link.data('toggle-trigger') || 'click'

    link.on trigger, (e)->
      e.preventDefault()

      linkTarget = $( link.data('toggle-target') )
      linkTarget.toggle()

      if linkTarget.css('display') == 'none'
        link.text link.data('toggle-show-text') || 'show'
      else
        link.text link.data('toggle-hide-text') || 'hide'
