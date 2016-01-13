class @FR2.Autocompleter
  constructor: (@form)->
    @input = @form.find "input[data-autocomplete]"
    @responseCache = {}

    @addAutocompleter()

  addAutocompleter: ->
    autocompleter = this

    @input.autocomplete({
      minLength: 3,
      source: (request, response) ->
        autocompleterInput = autocompleter.input

        if autocompleter.responseCache[request.term]
          $(autocompleterInput).siblings(".loader").remove()
          response autocompleter.responseCache[request.term]
        else
          $.ajax({
            url: autocompleter.form.data('autocomplete').endpoint + request.term,
            success: (data)->
              $(autocompleterInput).siblings(".loader").remove()

              result = $.map(data, (item)->
                return {
                  label: item.name,
                  value: item.name,
                  url: item.url,
                  id: item.id
                }
              )

              autocompleter.responseCache[request.term] = result
              response result
          })
      select: (event, ui)->
        autocompleter.input.val(ui.item.name)
        window.location.href = ui.item.url
      close: ->
        autocompleter.input.val('')
      search: (event, ui)->
        autocompleter.input.after $('<div>').addClass('loader')
    })
