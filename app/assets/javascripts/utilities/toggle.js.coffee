class @CJ.Toggle
  constructor: (el)->
    @el = $(el)
    @parent = $(@el.parents().first())

    @addToggleEvent()

class @CJ.ToggleOne extends @CJ.Toggle
  addToggleEvent: ()->
    @parent.on @el.data('toggle-trigger'), ".toggle", (event)->
      event.preventDefault()
      el = $(this)

      $(el.data('toggle-target')).toggle()

class @CJ.ToggleAll extends @CJ.Toggle
  addToggleEvent: ()->
    @parent.on @el.data('toggle-trigger'), ".toggle-all", (event)->
      event.preventDefault()
      el = $(this)

      $(el.data('toggle-all-targeters'))
        .removeClass(el.data('active-class') || 'active')

      $(el.data('toggle-all-target')).hide()
      $(el.data('toggle-target')).show()

      el.closest(el.data('toggle-all-targeters'))
        .addClass(el.data('active-class') || 'active')
