getAuthenticityTokenFromForm = (el)->
  el.closest('form').find('input[name=authenticity_token]').val()

getAuthenticityTokenFromHead = ()->
  $('meta[name="csrf-token"]').attr('content')

$(document).ready ->
  # set the CSRF token to the one in the element's form
  # if there is a form, otherwise use the one in the header
  # this requires the context to be set on the ajax block
  # making the call context: {element: this}
  $.ajaxSetup({
    beforeSend: (xhr, settings)->
      if settings.context? && settings.context.element?
        el = $(settings.context.element)
        if el.closest('form')?
          xhr.setRequestHeader(
            'X-CSRF-Token',
            getAuthenticityTokenFromForm(el)
          )
        else
          xhr.setRequestHeader(
            'X-CSRF-Token',
            getAuthenticityTokenFromHead()
          )
      else
        xhr.setRequestHeader(
          'X-CSRF-Token',
          getAuthenticityTokenFromHead()
        )
  })
