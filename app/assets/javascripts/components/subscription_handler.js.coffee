class @FR2.SubscriptionHandler
  @generateModal: ->
    FR2.Modal.displayModal('', @modalHtml(), {
      includeTitle: false
      modalClass: 'subscription-modal wide'
    })

    @addModalBehavior()

  @addModalBehavior: ->
    @addEmailHelper()
    @handleSubmit()

  @addEmailHelper: ->
    emailHelper = new EmailHelper()

    # watch input and debounce
    $('.fr-modal form.subscription').on 'input onpropertychange', '#subscription_email', ()->
      input = $(this)
      clearTimeout input.data('timeout')

      if !emailHelper.initialized
        emailHelper.initialize input

      emailHelper.reset_help_text()

      # debounce input changes
      emailCallback = -> emailHelper.validate_or_suggest()
      input.data('timeout', setTimeout emailCallback, 500)

    # add ability to use the suggested correction
    $('.fr-modal form.subscription').on 'click', '.email_suggestion .link', ->
      emailHelper.use_suggestion $(this)

  @handleSubmit: ->
    $('.fr-modal form.subscription .commit.button').on 'click', (e)->
      e.stopPropagation()
      $(this).closest('form.subscription').submit()

    $('.fr-modal form.subscription').on 'submit', (e)->
      console.log 'prevent submit'
      e.preventDefault()
      e.stopPropagation()

      form = $(this)
      subscription = form.find("input:radio[name='subscription[search_type]']:checked")
      subscriptionWrapper = form
        .find("input:radio[name='subscription[search_type]']")
        .closest('li.radio')
      email = form.find('#subscription_email')

      email.removeClass('error')
      subscriptionWrapper.removeClass('error')

      if subscription.val()
        if email.val()
          subscriptionParam = $.param({
            'subscription': {
              'search_conditions': subscription.data('subscription-params')
              'email': email.val()
            }
          })

          form.attr('action', "/my/subscriptions?#{subscriptionParam}")

          form.find('.button.commit').addClass('submitting')
          form.find('.button.commit input').prop('disabled', true)

          form
            .unbind('submit')
            .submit()
        else
          email.addClass('error').focus()
      else
        subscriptionWrapper.addClass('error')


  @modalHtml: ->
    elements = _.map @subscriptionFeeds(), (feed)=>
      @extractDataFromFeed $(feed)

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
      documentSubscriptionParams: JSON.stringify feed.data('document-search-conditions')
      publicInspectionSubscriptionParams: JSON.stringify feed.data('public-inspection-search-conditions')
      defaultSearchType: feed.data('default-search-type')
    }

    if data.documentSubscriptionParams || data.publicInspectionSubscriptionParams
      data.emailSubscriptionAction = true

    return data
