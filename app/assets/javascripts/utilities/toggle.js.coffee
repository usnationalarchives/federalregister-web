class @CJ.Toggle
  constructor: (el)->
    @el = $(el)
    @parent = $(@el.parents().first())

    @settings = @el.data('toggle')

    if !@settings || (@settings && !@settings.toggleTarget)
      error = new Error('CJ.Toggle :: Must provide toggleTarget as a data-toggle option')
      throw error

    defaults = {
      activeClass: 'active',
      hiddenClass: 'hidden'
      hideText: 'hide'
      showText: 'show'
      textTarget: @el
      toggleIgnore: '.no-toggle'
      toggleTarget: null
      trigger: 'click'
    }

    @settings =  Object.assign(defaults, @settings || {})

    @prepTargets()
    @addToggleEvent()

  # prep target for hidding via js by removing the css class that hides
  # elements on page load
  prepTargets: ()->
    toggler = this

    _.each $(@settings.toggleTarget), (target)->
      target = $(target)

      if target.hasClass(toggler.settings.hiddenClass)
        target.hide().removeClass(toggler.settings.hiddenClass)

class @CJ.ToggleOne extends @CJ.Toggle
  addToggleEvent: ()->
    toggler = this

    @parent.on @settings.trigger, ".toggle", (event)->
      event.preventDefault()
      el = $(this)

      $(toggler.settings.toggleTarget).not(toggler.settings.toggleIgnore).toggle()

      if $(toggler.settings.toggleTarget).last().css('display') == 'none'
        $(toggler.settings.textTarget).text toggler.settings.showText
      else
        $(toggler.settings.textTarget).text toggler.settings.hideText

class @CJ.ToggleAll extends @CJ.Toggle
  addToggleEvent: ()->
    toggler = this

    @parent.on @settings.trigger, ".toggle-all", (event)->
      event.preventDefault()
      el = $(this)

      $(toggler.settings.toggleAllTargeters)
        .removeClass(toggler.settings.activeClass)

      $(toggler.settings.toggleAllTarget).hide()
      $(toggler.settings.toggleTarget).show()

      el.closest(toggler.settings.toggleAllTargeters)
        .addClass(toggler.settings.activeClass)
