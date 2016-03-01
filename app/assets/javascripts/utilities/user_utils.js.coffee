class @FR2.UserUtils
  @loggedIn: ->
    if readCookie('expect_signed_in') == "1"
      return true
    else if readCookie('expect_signed_in') == "0"
      return false
    else
      return false
