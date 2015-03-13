$(document).ready(function(){
  $('.toggle').on('click', function(e) {
    e.preventDefault();

    var link = $(this);
    var linkTarget = $( link.data('toggleTarget') );

    linkTarget.toggle();

    if (linkTarget.css('display') == 'none') {
      link.text(link.data('show-text') || 'more');
    } else {
      link.text(link.data('hide-text') || 'hide');
    }
  });
});
// RW: coffeescript
