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


    currentModal.jqmShow().centerScreen()
    @addCloseHandler(options.modalId)

  @addCloseHandler: (modalId)->
    $("#{modalId}").jqm({
      onHide: (hash) ->
        hash.w.fadeOut(
          '400',
          -> hash.o.remove()
        )
        $("#{modalId}").trigger('modalClose')
    })

  @closeModal: (modalId)->
    $("#{modalId}").jqmHide()
    $("#{modalId}").trigger('modalClose')
