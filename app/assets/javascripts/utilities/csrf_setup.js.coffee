window.getAuthenticityTokenFromHead = ()->
  $('meta[name="csrf-token"]').attr('content')

$(document).ready ->
  # set the CSRF token to the one in the element's form
  # if there is a form, otherwise use the one in the header
  # this requires the context to be set on the ajax block
  # making the call context: {element: this}
  $.ajaxSetup({
    beforeSend: (xhr, settings)->
      xhr.setRequestHeader(
        'X-CSRF-Token',
        getAuthenticityTokenFromHead()
      )
  })

$(document).on 'submit', 'form[method=post]', (event) ->
  hiddenField = $('<input type="hidden" name="authenticity_token">')
  hiddenField.val(getAuthenticityTokenFromHead)
  hiddenField.appendTo(event.currentTarget)
  true
