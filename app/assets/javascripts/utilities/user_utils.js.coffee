class @FR2.UserUtils
  @loggedIn: ->
    if @_readCookie('expect_signed_in') == "1"
      return true
    else if @_readCookie('expect_signed_in') == "0"
      return false
    else
      return false

  @_readCookie: (name) ->
    nameEQ = name + '='
    ca = document.cookie.split(';')

    i = 0
    while i < ca.length
      c = ca[i]
      while c.charAt(0) == ' '
        c = c.substring(1, c.length)
      if c.indexOf(nameEQ) == 0
        return c.substring(nameEQ.length, c.length)
      i++

    null
