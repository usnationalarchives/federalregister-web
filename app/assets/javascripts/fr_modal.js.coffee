$(document).ready ->

  $('#main').on 'click', 'a.fr_modal, a.fr_modal_link', (event)->
    event.preventDefault()

    modalLink = $(this)

    modal_title    = modalLink.data('modal-title')
    modal_template = $("##{modalLink.data('modal-template-name')}")
    modal_data     = modalLink.data('modal-data')

    #ensure template exists on page
    modal_html = ''
    if ( modal_template.length > 0 )
      modal_html = Handlebars.compile(
        modal_template.html()
      )(modal_data)
    else
      modal_html = modalLink.data('modal-html')

    FR2.Modal.displayModal(modal_title, modal_html)
