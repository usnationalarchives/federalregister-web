class @FR2.ExternalLinkChecker
  INTERNAL_DOMAINS = [
    "localhost",
    "www.federalregister.gov",
    "fr2.criticaljuncture.org"
    "federalregister.tenderapp.com"
  ]

  constructor: (@click_event) ->
    if @click_event.target.localName == "a" && !@isInternalDomain(@click_event.target.href) && @isExternalUrl(@click_event.target.href) && @canShowModal()
      @click_event.preventDefault()
      @url = @click_event.target.href
      @displayModal()

  displayModal: ->
    context = @
    modalBody = Handlebars.compile($('#external-link-warning-modal-template').html())({
      url: @url
    })

    window.FR2.Modal.displayModal(
      'You Are Now Leaving the Federal Register',
      modalBody,
      {modalClass: 'fr-modal external-link-warning-modal'}
    )

    @bindModalListeners()

  bindModalListeners: ->
    $('#fr_modal.external-link-warning-modal form').submit (e) =>
      e.preventDefault()

      if $('#fr_modal.external-link-warning-modal [name=accept').prop('checked')
        amplify.store('showExternalModal', false, expires: 2592000000)

      window.location.href = @url

  canShowModal: ->
    amplify.store('showExternalModal') != false

  isExternalUrl: (url) ->
    relativeUrlRegex = RegExp('^(https?:)//')

    if relativeUrlRegex.test(url)
      true

  isInternalDomain: (url) ->
    isInternal = false
    $.each INTERNAL_DOMAINS, (i, internalDomain) ->
      if RegExp("^https?://#{internalDomain}").test(url)
        isInternal = true

    isInternal
