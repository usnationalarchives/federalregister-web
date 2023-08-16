/* determine whether to expect a current user */
function expect_logged_in() {
  if ( readCookie('expect_signed_in') === "1" ) {
    return true;
  } else if ( readCookie('expect_signed_in') === "0") {
    return false;
  } else {
    return false;
  }
}

function update_user_clipped_document_count(stored_documents) {
  //document_count = stored_documents !== undefined ? Object.keys(stored_documents).length : 0;
  var document_count = parseInt( $('#document-count #doc_count').html(), 10 );
  $('#document-count #doc_count').html( document_count + 1 );
}

function update_user_folder_count(folder_object) {
  var folder_count = parseInt( $('#document-count-holder #user_folder_count').html(), 10 );
  $('#user_folder_count').html( folder_count + 1 );
  }

function update_user_folder_document_count(folder_object) {
  var folder_docs_count = parseInt( $('#document-count-holder #user_documents_in_folders_count').html(), 10 );
  $('#user_documents_in_folders_count').html( folder_docs_count + 1 );
  }

function update_user_folder_and_document_count(folder_object) {
  update_user_folder_count(folder_object);
  update_user_folder_document_count(folder_object);
  }

// No calling function - likely dead code
// function document_number_present(document_number, user_folder_details) {
//   return _.filter( user_folder_details.folders, function(folder) {
//     /* return the folder if it has the document in it */
//     return $.inArray( document_number, folder.documents) > -1;
//   }).length !== 0;
// }

function show_folder_success(response) {
  var new_p = $('<p>').append(
    'Successfully created folder "' + response.folder.name + '"'
  ).append(
    $('<span>').addClass('icon-fr2 icon-fr2-badge_check_mark')
  );
  $('#new-folder-modal .folder_success p').replaceWith( new_p );
  $('#new-folder-modal .folder_success').show();
}

function set_clipped_icon_status() {
  if ( $('#add-to-folder .menu li.in_folder').length > 0 ) {
    $('#add-to-folder .button .icon').addClass('clipped');
  } else {
    $('#add-to-folder .button .icon').removeClass('clipped');
  }
}

function closeOnEscape(hash) {
  $(window).one('keyup', function(event) {
    if( event.keyCode === '27' ){
      hash.w.jqmHide();
    }
  });
}

/* jshint ignore:start */
var myfr2_jqmHandlers = {
  href: "",
  timer: "",
  show: function (hash) {
      hash.w.show();
      closeOnEscape(hash);
  },
  hide: function (hash) {
      hash.w.hide();
      hash.o.remove();
  }
};
/* jshint ignore:end */
