$(document).ready(function () {
  $('form.add_to_clipboard').hide();
  $('div.share a.flag_for_later').css('display', 'block');

  var current_document_id = $('form.add_to_clipboard input#entry_document_number').val();
  //var stored_documents = amplify.store("document_ids");
  
  // visually identify the document as flagged if it has been
  if( stored_document_numbers !== undefined && stored_document_numbers[current_document_id] !== undefined ) {
    $('div.share a.flag_for_later').addClass('flagged');
  }

  $('div.share a.flag_for_later').bind('click', function(event) {
    event.preventDefault();
    
    // add to users list
    //add_to_document_ids( current_document_id, [0]);

    $('div.share a.flag_for_later').addClass('flagged');

    //console.log( amplify.store("document_ids") );
    //stored_documents = amplify.store("document_ids");

    // if( readCookie('expect_logged_in') === "true" ) {
      $('form.add_to_clipboard').submit();
    // } else {
      // if the user isn't logged in, add to our list so we can
      // save them if/when they do
      // add_to_new_document_ids(current_document_id);
    // }

    update_user_clipped_document_count( stored_document_numbers );
  });

  $('form.add_to_clipboard').bind('submit', function(event) {
    event.preventDefault();
    $.ajax({
      url: $(this).prop('action'),
      data: $(this).serialize(),
      type: "POST",
      success: function(){
        $(this).addClass("done");
      }
    });
  });

});

