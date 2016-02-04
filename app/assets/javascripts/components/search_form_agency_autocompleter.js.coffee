class @FR2.SearchFormAgencyAutocompleter
  constructor: (@searchForm)->
    @agencyInput = @searchForm
      .find("input[data-autocomplete]#document-agency-search")

    @addAutocompleter()

  addAutocompleter: ->
    @searchForm
      .find("select[multiple]")
      .hide()
      .bsmSelect(
        {
          removeClass: 'remove icon-fr2 icon-fr2-badge_x'
          removeLabel: ''
        }
      )

    agencyAutocompleter = this
    @agencyInput.autocomplete(
      {
        minLength: 3
        source: (request, response)->
          agencyInput = agencyAutocompleter.agencyInput

          $.ajax({
            url: "/agencies/suggestions?term=" + request.term,
            success: (data) ->
              $(agencyInput).siblings(".loader").remove()

              response $.map(data, (item)->
                return {
                  label: item.name,
                  value: item.name,
                  id: item.slug
                }
              )
          })
        select: (event, ui)->
          $("#conditions_agencies")
            .append("<option value=#{ui.item.id} selected='selected'>#{ui.item.label}</option>")
          $("#conditions_agencies").trigger("change")
          $(this).data('clear-value', 1)
        close: ()->
          input = $(this)
          if input.data('clear-value')
            input.val('')
            input.data('clear-value',0)
        search: (event, ui)->
          $(this).after $('<div>').addClass('loader')
      }
    )
