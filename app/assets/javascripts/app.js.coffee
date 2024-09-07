# manipulating the DOM before it's rendered to avoid flash of content
$(document).on "DOMContentLoaded", (event)->
  (new OFR.ContentNotifications(FR2.UserPreferenceStore)).hideIgnored()


$(document).ready ()->
  new FR2.HoneybadgerConfigurer()

  userData = new FR2.UserData()
  new FR2.UserNavigationManager(userData)

  # Create an object to store non-persistent user data
  FR2.currentUserStorage = new FR2.NonPersistentStorage()
  FR2.currentUserStorage.set('userEmailAddress', userData.email)

  # Ensure user preference store has defaults
  FR2.UserPreferenceStore.init()

  (new OFR.ContentNotifications(FR2.UserPreferenceStore)).addEvents()

  tooltipOptions = {
    offset:  5
    opacity: 0.9
    delay:   0.3
    fade:    true
    html:    true
  }

  # Tooltips
  CJ.Tooltip.addTooltip(
    '.cj-tooltip',
    tooltipOptions
  )

  # Toggle show/hides
  $('.toggle').each (i, el)->
    new CJ.ToggleOne(el)

  $('.toggle-all').each (i, el)->
    new CJ.ToggleAll(el)

  # Nav Analytics
  $('.dropdown.nav_myfr2 ul.subnav li a:not(.inactive)').each ->
    $(this).bind 'click', ->
      @FR2.Analytics.trackMyFR2NavigationEvent($(this).html())

  # Calendars
  standardCalendars = $('.calendar-wrapper:not(.cal-double) table.calendar')
  standardCalendars.each (i, calendar)->
    new FR2.Calendar $(calendar)

  multiCalendars = $('.calendars-wrapper')
  multiCalendars.each (i, wrapper)->
    new FR2.MultiCalendarHandler $(wrapper).find('table.calendar')

  # Analytics
  $('#comment-bar.comment').on 'click', '.button.formal_comment.how_to_comment', ->
    button = $(this)

    category = 'Comment: How to Comment'
    action = button.attr('href')
    documentNumber = button.closest('div.comment').data('document-number')

    FR2.Analytics.trackGAEvent category, action, documentNumber

  # GA4 Generic handler for click tracking
  $('.fr-ga-event').on 'click', (e) ->
    eventName = $(this).data('eventName')
    if !eventName
      throw new Error('event_name must be defined')
    eventParameters = $(this).data('eventParameters')

    gtag('event', eventName, eventParameters)

  # Print View
  (new FR2.PrintViewManager).setup()

  # Site Feedback
  documentPageRegEx = new RegExp('\/documents\/\\d{4}')
  contentPage = () ->
    documentPageRegEx.test(window.location.href)

  new OFR.SiteFeedbackHandler(contentPage(), FR2.InterstitialModalHandler)

  # Subcription modals
  $('a.rss, a.subscription, a.subscription_action').not('.no-modal-action').on 'click', (e)->
    e.preventDefault()

    FR2.SubscriptionHandler.generateModal()

  # Document clipper(s)
  $.ajax({
    url: "/api/v1/clippings",
    dataType: "json",
    excludeCsrfTokenHeader: true,
    success: (data)->
      FR2.currentUserStorage.set('userFolderDetails', {folders: data.folders})

      stored_document_numbers = {}
      data.clippings.forEach (clipping) ->
        stored_document_numbers[clipping.document_number] ||= []

        slug = if clipping.folder
          clipping.folder.slug
        else
          'my-clipboard'

        stored_document_numbers[clipping.document_number].push(slug)

      FR2.currentUserStorage.set('storedDocumentNumbers',
        [stored_document_numbers])

      FR2.documentClippers = []
      $('.document-clipping-actions').each (i, clipper)->
        FR2.documentClippers.push(new FR2.DocumentClipper(clipper))

      #clippings page - currently dependent on ajax call completion
      if $("#clipping-actions").length > 0
        new FR2.ClippingsManager('#clipping-actions')
      if( $('#clipping-actions #doc-type-filter').length > 0 )
        new FR2.DocTypeFilterManager
  })

  # External link modal
  $('body').on 'click', 'a:not(.formal_comment)', (e)->
    new FR2.ExternalLinkChecker(e)

  # Copy-to-clipboard links
  if $('.clipboard-copy').length > 0
    $('.clipboard-copy').on 'click', (e)->
      clipboard = new FR2.Clipboard
      successMessage = "Shorter document URL copied to clipboard"
      clipboard.copyToClipboard $(this).data('clipboardText')
      $('.tipsy .tipsy-inner').text(successMessage)

  if $("#fulltext_content_area").length > 0
    new FR2.FootnoteHandler
    new FR2.ContentCopyToClipboard
    new FR2.ParagraphCitation $('#fulltext_content_area')


  ##############################
  # Agencies Page
  ##############################

  if $("#agency-list").length > 0
    new FR2.AgencyListFilter('#agency-list')
    new FR2.AgencyListSorter('#agency-list')

  new FR2.AgencyLogoPositioner


  ##############################
  # Clippings Page
  ##############################

  # set the size of the clipping data div to match the size of the
  # document data div (which we assume is larger) so that we get our
  # nice dashed border seperating the two
  $('ul#clippings li div.clipping_data').each (i, el)->
    $(el).height(
      $(el).siblings('div.document_data').height()
    )

  # also set the size of the add to folder pane and position checkbox
  # delay 200ms to allow for final page paint with webfonts (and thus element size)
  setTimeout(
    ()->
      $('ul#clippings li div.add_to_folder_pane').each (i, el)->
        $(el).height(
          $(el).closest('ul#clippings li').innerHeight()
        )

        inputEl = $(el).find('input').last()
        inputEl.css(
          'margin-top',
          ($(el).height() / 2) - (inputEl.height() / 2)
        )
    200
  )

  ##############################
  # EO Disposition Tables
  ##############################

  modalLinks = $('.fr-archives-pdf-links-modal-js')
  if modalLinks.length > 0
    renderModal = (response) ->
      if Object.keys(response).length > 1
        template = HandlebarsTemplates['fr_archives_download_links_modal']
        modalContents = template(response)
      else
        modalContents = "No historical content could be located for the provided citation.  If you suspect this may be an error, you can let us know by using the 'Site Feedback' button below."

      modalTitle = "Download Historical Content (EO " + response.eoNumber + ")"
      FR2.Modal.displayModal(
        modalTitle,
        modalContents
      )

    $('.fr-archives-pdf-links-modal-js').on 'click', (e) ->
      e.preventDefault()
      volume = $(this).data('archivesVolumeJs')
      page   = $(this).data('archivesPageJs')
      eoNumber = $(this).data('eoNumber')

      $.ajax({
        url: "https://#{window.location.host}/api/archives/v1/citation.json",
        method: 'GET',
        data: {volume: volume, page: page},
        success: (data) ->
          data.eoNumber = eoNumber
          renderModal(data)
        error: () ->
          renderModal({eoNumber: eoNumber})
      })


  ##############################
  # Documents Page
  ##############################

  if $("#comment-bar").length > 0
    new FR2.CommentBarHandler


  ##############################
  # Search Page
  ##############################

  if $(".search").length > 0
    pagers = $('.search .result-set .pagination')

    pagers.each (i, pager) ->
      $(pager)
        .css 'width', $(pager).width() + 5
        .css 'display', 'block'

  ##############################
  # Subscriptions Page
  ##############################

  if $(".subscription-actions").length > 0
    new FR2.SubscriptionFilter(
      $('.subscription-actions'),
      subscriptionTypeFilters
    )


  ##############################
  # Topics Page
  ##############################

  if $("#topic-list").length > 0
    new FR2.TopicListFilter('#topic-list')
    new FR2.TopicListSorter('#topic-list')

  ##############################
  # Utility Nav
  ##############################

  if $(".doc-content.with-utility-nav").length > 0
    new FR2.UtilityNav(".doc-content.with-utility-nav")

  ##############################
  # Collapsible Open Search Score Score Explanations
  ##############################
  $('.score-explanation-js').each (index, element) ->
    data = $(element).data('json')
    $(element).jsonViewer(data, {collapsed: true})
