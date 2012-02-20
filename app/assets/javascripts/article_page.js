function document_number_present(document_number, stored_document_numbers) {
  return _.filter( stored_document_numbers, function(item){ 
    return document_number in item; 
  }).length !== 0;
}

function add_item_to_folder(el) {
  el.find('.icon').toggle();
  el.find('.loader').toggle();
  
  form = $('form.add_to_clipboard');
  form_data = form.serializeArray();
  form_data.push( {name: "entry[folder]", value: el.data('slug')} );

  $.ajax({
    url: form.prop('action'),
    data: form_data,
    type: "POST"
  }).success(function(response) {
      el.removeClass('not_in_folder').addClass('in_folder');
    })
    .complete(function(response) {
      el.find('.loader').toggle();
      el.find('.icon').toggle();
    });

  /* visually mark the icon as in at least one folder */
  /* and increment the document count                 */
  $('div.share a.flag_for_later').addClass('flagged');
  update_user_clipped_document_count( stored_document_numbers );
}


$(document).ready(function () {
  $('form.add_to_clipboard').hide();

  $('form.add_to_clipboard').bind('submit', function(event) {
    event.preventDefault();
  });


  $('div.share a.flag_for_later').css('display', 'block');
  var current_document_number = $('form.add_to_clipboard input#entry_document_number').val();
  
  // visually identify the document as flagged if it has been
  if( stored_document_numbers !== undefined && document_number_present(current_document_number, stored_document_numbers) ) {
    $('div.share a.flag_for_later').addClass('flagged');
  }

  /* Add to Folder Menu */
  if ( $("#add-to-folder-menu-fr2-template") ) {
    add_to_folder_menu_fr2_template = Handlebars.compile( $("#add-to-folder-menu-fr2-template").html() );
  }

  user_folder_details.current_document_number = current_document_number;

  $('div.share li.clip_for_later').append($('<div>').addClass("fr2").prop('id', 'clipping-actions').append( add_to_folder_menu_fr2_template(user_folder_details) ) );

  $('#clipping-actions.fr2 #add-to-folder').live('hover', function() {
    $(this).find('.menu').toggle();
  });
  
  $('#clipping-actions.fr2 #add-to-folder .menu li').live('click', function(event) { event.preventDefault(); });

  $('#clipping-actions.fr2 #add-to-folder .menu li.not_in_folder').live('click', function(event) {
    event.preventDefault();
    add_item_to_folder( $(this) );
  });

});

