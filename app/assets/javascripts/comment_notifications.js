$(document).ready( function() {
  $('#metadata_content_area').delegate('.comment_next_steps .my_fr a.notifications', 'click', function(event) {
    event.preventDefault();

    var $link = $(this);

    $.ajax({
      url: $link.attr('href'),
      dataType: 'json',
      type: $link.data('method'),
      data: {comment_tracking_number: $link.data('comment-tracking-number')},
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      },
      success: function(response) {
        $link.html( response.link_text );
        $link.data('method', response.method);
      }
    });
  });
});


