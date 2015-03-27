$(document).ready(function(){
  $('.toggle').on('click', function(e) {
    e.preventDefault();

    var link = $(this);
    var linkTarget = $( link.data('toggle-target') );

    linkTarget.toggle();

    if (linkTarget.css('display') == 'none') {
      link.text(link.data('toggle-show-text') || 'show');
    } else {
      link.text(link.data('toggle-hide-text') || 'hide');
    }
  });
});
// RW: coffeescript
