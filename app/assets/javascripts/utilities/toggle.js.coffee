class @CJ.Toggle
  constructor: (el)->
    @el = $(el)
    @parent = $(@el.parents().first())

    @settings = @el.data('toggle')

    if !@settings || (@settings && !@settings.toggleTarget)
      throw 'CJ.Toggle :: Must provide toggleTarget as a data-toggle option'

    defaults = {
      hiddenClass: 'hidden'
      hideText: 'hide'
      showText: 'show'
      textTarget: @el
      toggleTarget: null
      trigger: 'click'
    }

    @settings = _.extend({}, defaults, @settings)

    @prepTargets()
    @addToggleEvent()

class @CJ.ToggleOne extends @CJ.Toggle
  addToggleEvent: ()->
    toggler = this

    @parent.on @settings.trigger, ".toggle", (event)->
      event.preventDefault()
      el = $(this)

      $(toggler.settings.toggleTarget).toggle()

      if $(toggler.settings.toggleTarget).last().css('display') == 'none'
        $(toggler.settings.textTarget).text toggler.settings.showText
      else
        $(toggler.settings.textTarget).text toggler.settings.hideText

  # prep target for hidding via js by removing the css class that hides
  # elements on page load
  prepTargets: ()->
    toggler = this

    _.each $(@settings.toggleTarget), (target)->
      target = $(target)

      if target.hasClass(toggler.settings.hiddenClass)
        target.hide().removeClass(toggler.settings.hiddenClass)

class @CJ.ToggleAll extends @CJ.Toggle
  addToggleEvent: ()->
    @parent.on @settings.trigger, ".toggle-all", (event)->
      event.preventDefault()
      el = $(this)

      $(el.data('toggle-all-targeters'))
        .removeClass(el.data('active-class') || 'active')

      $(el.data('toggle-all-target')).hide()
      $(el.data('toggle-target')).show()

      el.closest(el.data('toggle-all-targeters'))
        .addClass(el.data('active-class') || 'active')
