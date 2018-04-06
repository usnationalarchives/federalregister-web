class @FR2.UserNavigationManager
  constructor: (userData) ->
    @userData = userData
    @updateMyFRNav()

  updateMyFRNav: ->
    if @userData.signedIn()
      $('.myfr2-clipboard').removeClass('inactive')
      $('.myfr2-comments').removeClass('inactive')
      $('.myfr2-subscriptions').removeClass('inactive')
      $('.my-account-link').removeClass('inactive')
    else
      $('.myfr2-clipboard').addClass('inactive')
      $('.myfr2-comments').addClass('inactive')
      $('.myfr2-subscriptions').addClass('inactive')
      $('.my-account-link').addClass('inactive')
