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
