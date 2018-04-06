class @FR2.UserData
  constructor: ->
    userData = Cookies.getJSON('user_data')

    if userData && userData.email
      @email = userData.email
    else
      @email = null

  signedIn: ->
    @email && @email.length > 0

  email: ->
    @email
