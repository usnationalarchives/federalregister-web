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
