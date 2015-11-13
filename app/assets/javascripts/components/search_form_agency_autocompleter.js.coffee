class @FR2.SearchFormAgencyAutocompleter
  constructor: (@searchForm)->
    @agencyInput = @searchForm
      .find("input[data-autocomplete]#document-agency-search")

    @addAutocompleter()

  addAutocompleter: ->
    @searchForm
      .find("select[multiple]")
      .hide()
      .bsmSelect({removeClass: 'remove'})

    @agencyInput.autocomplete(
      {
        minLength: 3
        source: (request, response)->
          elem = @agencyInput

          $.ajax({
            url: "/agencies/suggestions?term=" + request.term,
            success: (data) ->
              $(elem).removeClass("loading")

              response $.map(data, (item)->
                return {
                  label: item.name,
                  value: item.name,
                  id: item.id
                }
              )
          })
        select: (event, ui)->
          $("#conditions_agency_ids")
            .append("<option value=#{ui.item.id} selected='selected'>#{ui.item.label}</option>")
          $("#conditions_agency_ids").trigger("change")
          $(this).data('clear-value', 1)
        close: ()->
          input = $(this)
          if input.data('clear-value')
            input.val('')
            input.data('clear-value',0)
        search: (event, ui)->
          $(this).addClass("loading")
      }
    )
