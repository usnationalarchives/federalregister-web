class @FR2.Calendar
  constructor: (@calendar)->
    @wrapper = @calendar.closest('.calendar-wrapper')

    @addYearDropdown()
    @addClickEvents()
    @addMissingDateHandler()
    @ensureTooltips()

  addYearDropdown: ->
    # only add year dropdown if it doesn't already exist
    if @calendar.find('.monthName select').length == 0 && @calendar.data('year-select') == true
      @select = $('<select />')
      today = new Date()
      startYear = parseInt(@calendar.data('year-start'), 10)
      endYear = parseInt(@calendar.data('year-end'), 10)

      # ensure the data spans years before creating a year select list
      if endYear > startYear
        @buildSelect(year) for year in [startYear..endYear]
        @calendar.find('.monthName').append(@select)

        frCalendar = this
        @select.on 'change', @updateCalendarYear

  buildSelect: (year)->
    option = $("<option />").append(year)
    if parseInt(@calendar.attr("data-calendar-year"), 10) == year
      option.prop 'selected', true

    @select.append(option)

  updateCalendarYear: (event) =>
    event.stopPropagation()
    event.preventDefault()

    $.ajax({
      url: "#{@._calendarYearBaseUrl()}/#{$(event.target).val()}/#{@calendar.data('calendar-month')}"
      dataType: 'html'
      beforeSend: @showLoader
      complete: =>
        @calendar.find('.loader').remove()
      success: @swapCalendars
    })

  _calendarYearBaseUrl: =>
    if this.wrapper.data('document-type-js') == 'public-inspection'
      '/esi/public_inspection_issues'
    else
      "/esi/document_issues/"

  showLoader: =>
    @calendar.remove()
    @wrapper.append '<div class="loader" />'

  swapCalendars: (html)=>
    @wrapper.find('.loader').remove()
    @wrapper.append(html)
    new FR2.Calendar @wrapper.find('table.calendar')

  addClickEvents: ->
    @changeCalendarEvent()

  changeCalendarEvent: ->
    @calendar.on 'click', '.nav', (event)=>
      event.stopPropagation()
      event.preventDefault()

      navItem = $(event.target)
      @getNewCalendar(
        navItem.attr('href')
      )

  getNewCalendar: (url)=>
    $.ajax({
      url: url
      beforeSend: =>
        @showLoader()
      complete: =>
        @calendar.find('.loader').remove()
      success: @swapCalendars
    })


  addMissingDateHandler: ->
    @calendar.on 'click', 'td.late', (event)->
      event.preventDefault()
      window.alert "This issue is currently unavailable; we apologize for any inconvenience."

  ensureTooltips: ->
    CJ.Tooltip.addTooltip(
      @calendar.find('.cj-tooltip'),
      {
        offset: 5
        opacity: 0.9
        delay: 0.3
        fade: true
      }
    )

class @FR2.MultiCalendar extends @FR2.Calendar
  constructor: (calendar, handler)->
    @multiHandler = handler
    super(calendar)

  changeCalendarEvent: ->
    @calendar.on 'click', '.nav', (event)=>
      event.stopPropagation()
      event.preventDefault()

      @multiHandler.swapCalendars(@calendar)

  swapCalendars: (html)=>
    @wrapper.find('.loader').remove()
    @wrapper.append(html)

    calendar = @wrapper.find('table.calendar')
    @multiHandler.updateCalendar(calendar)

class @FR2.MultiCalendarHandler
  constructor: (calendars)->
    @calendarA = new FR2.MultiCalendar($(calendars[0]), this)
    @calendarB = new FR2.MultiCalendar($(calendars[1]), this)

  updateCalendar: (calendar)->
    if calendar.hasClass('cal_first')
      @calendarA = new FR2.MultiCalendar(calendar, this)
    else
      @calendarB = new FR2.MultiCalendar(calendar, this)

  swapCalendars: (calendar)->
    direction = if calendar.hasClass('cal_first') then 'backward' else 'forward'

    if direction == 'backward'
      @calendarA.getNewCalendar(
        @calendarA.calendar.find('.calendarPrev a').attr('href')
      )

      @calendarB.getNewCalendar(
        @calendarB.calendar.find('.calendarPrev a').attr('href')
      )
    else if direction == "forward"
      @calendarA.getNewCalendar(
        @calendarA.calendar.find('.calendarNext a').attr('href')
      )

      @calendarB.getNewCalendar(
        @calendarB.calendar.find('.calendarNext a').attr('href')
      )
