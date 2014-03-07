$(document).ready(function() {
  var nav_buttons = $('.nav-home-carousel .nav li'),
      nav_content_areas = $('.nav-home-carousel .nav-content');

  $('.nav-home-carousel .nav').on('click', 'li', function(event) {
    event.preventDefault();

    _.each(nav_buttons, function(button) {
      $(button).removeClass('selected');
    });

    $(this).addClass('selected');

    _.each(nav_content_areas, function(content) {
      $(content).hide();
    });

    $( $(this).data('toggle-target') ).show();
  });
});
