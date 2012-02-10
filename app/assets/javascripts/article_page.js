function document_number_present(document_number, stored_document_numbers) {
  return _.filter( stored_document_numbers, function(item){ 
    return document_number in item; 
  }).length !== 0;
}

$(document).ready(function () {
  $('form.add_to_clipboard').hide();

  $('form.add_to_clipboard').bind('submit', function(event) {
    console.log('submitting');
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


  $('div.share a.flag_for_later').css('display', 'block');
  var current_document_number = $('form.add_to_clipboard input#entry_document_number').val();
  
  // visually identify the document as flagged if it has been
  if( stored_document_numbers !== undefined && document_number_present(current_document_number, stored_document_numbers) ) {
    $('div.share a.flag_for_later').addClass('flagged');
  }

  $('div.share a.flag_for_later').bind('click', function(event) {
    event.preventDefault();
    
    $('div.share a.flag_for_later').addClass('flagged');
    $('form.add_to_clipboard').submit();

    update_user_clipped_document_count( stored_document_numbers );
  });

});

