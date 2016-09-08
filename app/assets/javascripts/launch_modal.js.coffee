$('document').ready ->
  if !amplify.store 'launchModalViewed'
    FR2.Modal.displayModal(
      'Welcome to the updated FederalRegister.gov!',
      Handlebars.compile($('#launch-modal-template').html())(),
      {modalClass: 'fr-modal extra-wide launch-modal'}
    )

    #amplify.store 'launchModalViewed', true
