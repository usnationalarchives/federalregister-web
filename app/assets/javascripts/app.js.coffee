# Create an object to store non-persistent user data to
# Needs instantiation before document ready as some of these values
# are set by script tags in the html
FR2.currentUserStorage = new FR2.NonPersistentStorage()

$(document).ready ()->
  new FR2.HoneybadgerConfigurer()

  userData = new FR2.UserData()
  new FR2.UserNavigationManager(userData)

  tooltipOptions = {
    offset:  5
    opacity: 0.9
    delay:   0.3
    fade:    true
  }

  # Tooltips
  CJ.Tooltip.addTooltip(
    '.cj-tooltip',
    tooltipOptions
  )

  # Toggle show/hides
  _.each $('.toggle'), (el)->
    new CJ.ToggleOne(el)

  _.each $('.toggle-all'), (el)->
    new CJ.ToggleAll(el)

  # Calendars
  standardCalendars = $('.calendar-wrapper:not(.cal-double) table.calendar')
  _.each standardCalendars, (calendar)->
    new FR2.Calendar $(calendar)

  multiCalendars = $('.calendars-wrapper')
  _.each multiCalendars, (wrapper)->
    new FR2.MultiCalendarHandler $(wrapper).find('table.calendar')

  # Analytics
  $('#comment-bar.comment').on 'click', '.button.formal_comment.how_to_comment', ->
    button = $(this)

    category = 'Comment: How to Comment'
    action = button.attr('href')
    documentNumber = button.closest('div.comment').data('document-number')

    FR2.Analytics.trackGAEvent category, action, documentNumber

  # Subcription modals
  $('a.rss, a.subscription, a.subscription_action').not('.no-modal-action').on 'click', (e)->
    e.preventDefault()

    FR2.SubscriptionHandler.generateModal()

  # Document clipper(s)
  FR2.documentClippers = []
  _.each $('.document-clipping-actions'), (clipper)->
    FR2.documentClippers.push(new FR2.DocumentClipper(clipper))

  # Add space above navigation for user utils
  if $('.logo').siblings('div#user_utils').length > 0
    $('.logo .hgroup').css('position', 'relative').css('top', '20px')

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

  # Fixed Header Handling
  if $('.doc-content-area').length > 0
    manager = new FR2.TableFixedHeaderManager(tooltipOptions)
    manager.perform()

  if $("#fulltext_content_area").length > 0
    new FR2.FootnoteHandler
    new FR2.ContentCopyToClipboard


  ##############################
  # Agencies Page
  ##############################

  if $("#agency-list").length > 0
    new FR2.AgencyListFilter('#agency-list')

  new FR2.AgencyLogoPositioner


  ##############################
  # Clippings Page
  ##############################

  if $("#clipping-actions").length > 0
    new FR2.ClippingsManager('#clipping-actions')

  # set the size of the clipping data div to match the size of the
  # document data div (which we assume is larger) so that we get our
  # nice dashed border seperating the two
  _.each $('ul#clippings li div.clipping_data'), (el)->
    $(el).height(
      $(el).siblings('div.document_data').height()
    )

  # also set the size of the add to folder pane and position checkbox
  # delay 200ms to allow for final page paint with webfonts (and thus element size)
  setTimeout(
    ()->
      _.each $('ul#clippings li div.add_to_folder_pane'), (el)->
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

  filter_clippings_by_type = (el) ->
    doc_type = el.data('filter-doc-type')

    # Note: doc_type_filters is defined in a script tag on the clippings page
    if ( el.hasClass('on') )
      el.removeClass('on')
      el.removeClass('hover')

      el.data('tooltip',
        'Show documents of type ' + el.data('filter-doc-type-display')
      )
      el.tipsy('hide')
      el.tipsy('show')

      index = _.indexOf(doc_type_filters, doc_type)
      doc_type_filters[index] = null
      doc_type_filters = _.compact(doc_type_filters)
    else
      el.addClass('on')

      el.data('tooltip',
        'Hide documents of type ' + el.data('filter-doc-type-display')
      )
      el.tipsy('hide')
      el.tipsy('show')

      doc_type_filters.push( doc_type );

    documents_to_hide = _.filter(
      $('ul#clippings li'),
      (clipping) ->
        ! _.include(doc_type_filters, $(clipping).data('doc-type') )
    )

    $('#clippings li').show();
    $(documents_to_hide).hide();

  if( $('#clipping-actions #doc-type-filter').length > 0 )
    $('#doc-type-filter li').each( ->
      if ( _.include( doc_type_filters, $(this).data('filter-doc-type') ) )
        $(this).addClass('on')
        $(this).data('tooltip',
          'Hide documents of type ' + $(this).data('filter-doc-type-display')
        )
      else
        $(this).addClass('disabled')
        $(this).data('tooltip',
          'No documents of type ' + $(this).data('filter-doc-type-display') + ' have been clipped'
        )
    )

    $('#doc-type-filter li:not(.disabled)').bind('mouseenter', ->
      $(this).addClass('hover')
    )

    $('#doc-type-filter li:not(.disabled)').bind('mouseleave', ->
      $(this).removeClass('hover')
    )

    $('#doc-type-filter li:not(.disabled)').bind('click', ->
      filter_clippings_by_type( $(this) )
    )


  ##############################
  # Documents Page
  ##############################

  if $("#comment-bar").length > 0
    commentLink = $('a#start_comment[data-comment=1]').get(0)
    republishedDocumentCommentUrl = $('#comment-bar').data('republished-document-comment-url')

    if (commentLink || window.location.hash == "#open-comment") && window.location.hash != '#addresses'
      FR2.commentFormHandlerInstance = new FR2.CommentFormHandler(
        $('#comment-bar.comment')
      )
    else if republishedDocumentCommentUrl
      new FR2.CommentingUnavailableHandler(
        $('#comment-bar.comment'),
        "<p>Submitting a formal comment directly via federalregister.gov may be available for the original document.  Click the button below to view the original document.</p></br><a href='#{republishedDocumentCommentUrl}' class='fr_button medium primary'>View Original Document</a>",
        false
      )
    else
      new FR2.CommentingUnavailableHandler(
        $('#comment-bar.comment'),
        "<p>Submitting a formal comment directly via federalregister.gov is not available for this document at this time.  However, you can click the button below to view more information on alternate methods of comment submission.</p></br><a class='fr_button medium primary jqm-close-js'>View Additional Information</a>"
      )


  ##############################
  # Search Page
  ##############################

  if $(".search").length > 0
    pagers = $('.search .result-set .pagination')

    _.each pagers, (pager) ->
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
    new FR2.TopicListSorter('#topic-list')


  ##############################
  # API Docs Page
  ##############################
  if $("#swagger-ui").length > 0
    window.ui = SwaggerUIBundle(
      url: "/api/v1/documentation.json",
      dom_id: '#swagger-ui',
      deepLinking: true,
      presets: [
        SwaggerUIBundle.presets.apis,
        SwaggerUIBundle.SwaggerUIStandalonePreset
      ],
      plugins: [
        SwaggerUIBundle.plugins.DownloadUrl
      ]
    )
