function get_user_state() {
  if( FR2.UserUtils.loggedIn() ) {
    return 'logged_in';
  } else {
    return 'logged_out';
  }
}

function get_page_type() {
  if( window.location.pathname.match(/\/search/) === null ) {
    return 'document';
  } else {
    return 'search';
  }
}

function get_folder_type(folder_slug) {
  if( folder_slug === 'my-clippings' ) {
    return 'clipboard';
  } else {
    return 'folder';
  }
}

function track_clipping_event(action, document_number, folder_slug) {
  /* current actions: add, remove */
  var user_state, page_type, folder_type, label;

  user_state  = get_user_state();
  page_type   = get_page_type();
  folder_type = get_folder_type(folder_slug);

  label = user_state + "/" + folder_type + "/" + page_type + "/" + document_number;

  gtag('event', 'Clipping', {'event_action': action, 'event_label': label});
}

function track_folder_event(action, document_count) {
  /* current actions: create */
  var user_state, page_type, folder_type, label;

  user_state  = "logged_in";
  page_type   = get_page_type();
  folder_type = "folder";

  label = user_state + "/" + folder_type + "/" + page_type;

  gtag('event', 'Folder', {'event_action': action, 'event_label': label, 'value': document_count});
}


$(document).ready(function(){
  // NAVIGATION
  $(".dropdown.nav_myfr2 ul.subnav li a").each(function() {
    $(this).bind('click', function() {
      gtag('event', 'Navigation', {'event_action': 'Navigation', 'event_label': 'MyFR', 'value': $(this).html()});
    });
  });
});
