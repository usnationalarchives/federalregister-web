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
