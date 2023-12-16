$(document).ready ->
  $('#delete-folder').on 'click', (event)->
    event.preventDefault()

    folderData = {
      numClippings: $('#clippings li').length,
      folderSlug: $('h2.title').data().folderSlug,
      token: $('meta[name="csrf-token"]').attr('content')
    }

    modalTemplate = HandlebarsTemplates['delete_folder_modal']

    FR2.Modal.displayModal(
      "", modalTemplate(folderData),
      {
        includeTitle: false,
        modalClass: 'delete-folder-modal'
      }
    )

    $('.delete-folder-modal .delete-folder-modal-button').on 'click', (e)->
      $(this).closest('form').submit()
