class @FR2.SubscriptionHandler
  @generateModal: ->
    FR2.Modal.displayModal('', @modalHtml(), {
      includeTitle: false
      modalClass: 'subscription-modal'
    })

    @addModalBehavior()

  @addModalBehavior: ->
    emailHelper = new EmailHelper()

    # watch input and debounce
    $('#modal form.subscription').on 'input onpropertychange', '#subscription_email', ()->
        input = $(this)
        clearTimeout input.data('timeout')

        if !emailHelper.initialized
          emailHelper.initialize input

        emailHelper.reset_help_text()

        # debounce input changes
        emailCallback = -> emailHelper.validate_or_suggest()
        input.data('timeout', setTimeout emailCallback, 500)

    # add ability to use the suggested correction
    $('#modal form.subscription').on 'click', '.email_suggestion .link', ->
      emailHelper.use_suggestion $(this)

  @modalHtml: ->
    elements = _.map @subscriptionFeeds(), (feed)=>
      data = @extractDataFromFeed $(feed)

    @modalTemplate()({
      elements: elements,
      email_address: FR2.currentUserStorage.get('userEmailAddress')
    })

  @modalTemplate: ->
    Handlebars.compile $("#subscription-modal-template").html()

  @subscriptionFeeds: ->
    $('link.subscription_feed')

  @extractDataFromFeed: (feed)->
    data = {
      title: feed.attr 'title'
      url: feed.attr 'href'
      escapedUrl: encodeURIComponent feed.attr('href')
    }

    if feed.data 'document-search-conditions'
      subscriptionParam = $.param({
        'subscription' : {
          'search_conditions' : $.parseJSON(
            feed.data('document-search-conditions')
          )
        }
      })
      data.documentSubscriptionAction = "/my/subscriptions?#{subscriptionParam}"

    if feed.data 'public-inspection-search-conditions'
      piSubscriptionParam = $.param({
        'subscription' : {
          'search_conditions' : $.parseJSON(
            feed.data('public-inspection-search-conditions')
          )
        }
      })
      data.publicInspectionSubscriptionAction = "/my/subscriptions?#{piSubscriptionParam}"

    if data.documentSubscriptionAction || data.publicInspectionSubscriptionAction
      data.subscriptionAction = true

    return data
