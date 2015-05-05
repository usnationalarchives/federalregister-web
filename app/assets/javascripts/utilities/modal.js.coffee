class @CJ.Modal
  @defaults: ()->
    {
      modalId:       '#disclaimer_modal'
      includeTitle:  true
      modalClass:    ''
    }

  @displayModal: (title, html, options)->
    options = _.extend @defaults, options

    currentModal = $(options.modalId)

    if currentModal.size() == 0
      $('body')
        .append "<div id='#{options.modalId.slice(1)}'/>"

      currentModal = $(options.modalId);
      currentModal
        .addClass options.modalClass


    modalContent = ['<a href="#" class="jqmClose">Close</a>']
    if options.includeTitle
      modalContent
        .push "<h3 class='title_bar'>#{title}</h3>"

    modalContent.push html

    currentModal
      .html modalContent.join("\n")

    currentModal.jqm({
      modal: true,
      toTop: true,
      onShow: modalOpen
    })


    currentModal.jqmShow().centerScreen();



