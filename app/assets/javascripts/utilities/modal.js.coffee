class @FR2.Modal
  @defaults: ()->
    {
      modalId: '#fr_modal'
      includeTitle: true
      modalClass: 'fr-modal'
    }

  @displayModal: (title, html, options)->
    options = _.extend @defaults(), options
    modalClass = "#{@defaults().modalClass} #{options.modalClass}"

    currentModal = $(options.modalId)

    if currentModal.length > 0
      currentModal.remove()

    $('body')
      .append "<div id='#{options.modalId.slice(1)}'/>"

    currentModal = $(options.modalId)
    currentModal
      .addClass modalClass


    modalContent = ['<a href="#" class="jqmClose" "aria-label"="close"><span class="icon-fr2 icon-fr2-badge_x"></span></a>']
    if options.includeTitle
      modalContent
        .push "<h3 class='title_bar'>#{title}</h3>"

    modalContent.push html

    currentModal
      .html modalContent.join("\n")

    currentModal.jqm({
      modal: true
      toTop: true
    })

    if options.alternateModalCloseSelector
      currentModal.jqmAddClose(options.alternateModalCloseSelector)

    @addAdditionalCloseHandler(options)
    @addAdditionalOpenHandler(options)

    currentModal.jqmShow().centerScreen()

  @addCloseHandler: (options)->
    $("#{options.modalId}").jqm({
      onHide: (hash) ->
        if options.onHide
          options.onHide(hash)
        else
          hash.w.fadeOut(
            '400',
            -> hash.o.remove()
          )
          $("#{options.modalId}").trigger('modalClose')
    })

  @addAdditionalCloseHandler: (options)->
    if options.additionalOnHide
      $("#{options.modalId}").jqm({
        onHide: (hash) ->
          options.additionalOnHide(hash)

          hash.w.fadeOut(
            '400',
            -> hash.o.remove()
          )
          $("#{options.modalId}").trigger('modalClose')
      })
    else
      @addCloseHandler(options)

  @addAdditionalOpenHandler: (options)->
    if options.additionalOnShow
      $("#{options.modalId}").jqm({
        onShow: (hash) ->
          options.additionalOnShow(hash)

          ## original function from jqm
          if hash.c.overlay > 0
            hash.o.prependTo('body')

          # make modal visible
          hash.w.show()

          # call focusFunc (attempts to focus on first input in modal)
          $.jqm.focusFunc(hash.w,true)

          return true
      })

  @closeModal: (modalId)->
    $("#{modalId}").jqmHide()
    $("#{modalId}").trigger('modalClose')
