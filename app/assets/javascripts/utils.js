$(document).ready(function() {
  $.each($('.toggle'), function(i, el) {
    var parent = $(el).parents().first();

    $(parent).on(
      $(el).data('toggle-trigger'),
      ".toggle",
      function(event) {
        event.preventDefault();

        $( $(this).data('toggle-target') ).toggle();
      }
    );
  });
});
