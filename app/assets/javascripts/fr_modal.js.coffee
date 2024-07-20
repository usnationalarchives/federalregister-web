$(document).ready ->

  $('#main').on 'click', 'a.fr_modal, a.fr_modal_link', (event)->
    event.preventDefault()

    modalLink = $(this)

    modal_title    = modalLink.data('modal-title')
    templateName   = CJ.convertTemplateNameToHandlebarsAssets(modalLink.data('modal-template-name'))
    modal_template = HandlebarsTemplates[templateName]
    modal_data     = modalLink.data('modal-data')

    #ensure template exists on page
    modal_html = ''
    if modal_template
      modal_html = modal_template(modal_data)
    else
      modal_html = modalLink.data('modal-html')

    FR2.Modal.displayModal(modal_title, modal_html)
