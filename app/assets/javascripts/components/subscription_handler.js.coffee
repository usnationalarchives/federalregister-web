class @FR2.SubscriptionHandler
  @generateModal: ->
    FR2.Modal.displayModal('', @modalHtml(), {
      includeTitle: false
      modalClass: 'subscription-modal wide'
    })

    @addModalBehavior()

  @addModalBehavior: ->
    @handleSubmit()

  @handleSubmit: ->
    $('.fr-modal form.subscription .commit.button').on 'click', (e)->
      e.stopPropagation()
      $(this).closest('form.subscription').submit()

    $('.fr-modal form.subscription').on 'submit', (e)->
      e.preventDefault()
      e.stopPropagation()

      form = $(this)
      subscription = form.find("input:radio[name='subscription[search_type]']:checked")
      subscriptionWrapper = form
        .find("input:radio[name='subscription[search_type]']")
        .closest('li.radio')
      searchType = form
        .find('input[name="subscription[search_type]"]:checked')
      email = form.find('#subscription_email')

      email.removeClass('error')
      subscriptionWrapper.removeClass('error')

      if subscription.val()
        subscriptionParam = $.param({
          'subscription': {
            'search_conditions': subscription.data('subscription-params')
            'search_type': searchType.val()
            'email': email.val()
          }
        })

        form.attr('action', "/my/subscriptions?#{subscriptionParam}")

        # add authenticity_token here as we are unbinding submit events below
        hiddenField = $('<input type="hidden" name="authenticity_token">')
        hiddenField.val(getAuthenticityTokenFromHead)
        hiddenField.appendTo(form)

        form.find('.button.commit').addClass('submitting')
        form.find('.button.commit input').prop('disabled', true)

        form
          .unbind('submit')
          .submit()
      else
        subscriptionWrapper.addClass('error')


  @modalHtml: ->
    elements = @subscriptionFeeds().toArray().map((feed)=>
      @extractDataFromFeed $(feed)
    )

    @modalTemplate()({
      elements: elements,
      email_address: FR2.currentUserStorage.get('userEmailAddress')
    })

  @modalTemplate: ->
    HandlebarsTemplates['subscription_modal']

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
