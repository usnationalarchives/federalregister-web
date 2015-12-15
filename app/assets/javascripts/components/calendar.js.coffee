class @FR2.Calendar
  constructor: (@calendar)->
    @addYearDropdown()
    @addClickEvents()
    @addMissingDateHandler()
    @ensureTooltips()

  addYearDropdown: ->
    # only add year dropdown if it doesn't already exist
    if @calendar.find('.monthName select').length == 0 && ! @calendar.hasClass('no_select')
      @select = $('<select />')
      today = new Date()
      startYear = parseInt(@calendar.data('year-start'), 10)
      endYear = parseInt(@calendar.data('year-end'), 10)

      # ensure the data spans years before creating a year select list
      if endYear > startYear
        @buildSelect(year) for year in [startYear..endYear]
        @calendar.find('.monthName').append(@select)

        frCalendar = this
        @select.on 'change', @updateCalendars

  buildSelect: (year)->
    option = $("<option />").append(year)
    if parseInt(@calendar.attr("data-calendar-year"), 10) == year
      option.prop 'selected', true

    @select.append(option)

  updateCalendars: (event) =>
    event.stopPropagation()
    event.preventDefault()

    $.ajax({
      url: "/esi/document_issues/#{$(event.target).val()}/#{@calendar.data('calendar-month')}"
      dataType: 'html'
    })
      .done @swapCalendars

  swapCalendars: (html)=>
      wrapper = @calendar.closest('.calendar-wrapper')
      wrapper.append(html)
      @calendar.remove()
      new FR2.Calendar wrapper.find('table.calendar')

  addClickEvents: ->
    #noop

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
