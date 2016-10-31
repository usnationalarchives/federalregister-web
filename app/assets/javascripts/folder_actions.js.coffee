$(document).ready ->
  $('#delete-folder').on 'click', (event)->
    event.preventDefault()

    folderData = {
      numClippings: $('#clippings li').size(),
      folderSlug: $('h2.title').data().folderSlug
    }

    modalTemplate = Handlebars.compile $("#delete-folder-modal-template").html()

    FR2.Modal.displayModal(
      "", modalTemplate(folderData),
      {
        includeTitle: false,
        modalClass: 'delete-folder-modal'
      }
    )

    $('.delete-folder-modal .delete-folder-modal-button').on 'click', (e)->
      $(this).closest('form').submit()
