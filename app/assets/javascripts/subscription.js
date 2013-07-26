function unsubscribe_success($link, response) {
  $link.removeClass('unsubscribe').addClass('resubscribe').html('resubscribe');
  $link.siblings('span.active').removeClass('active').addClass('inactive').html('inactive');
  $link.attr('href', response.resubscribe_url);
}

function resubscribe_success($link, response) {
  $link.removeClass('resubscribe').addClass('unsubscribe').html('unsubscribe');
  $link.siblings('span.inactive').removeClass('inactive').addClass('active').html('active');
  $link.attr('href', response.unsubscribe_url);
}


$(document).ready( function() {
  /* set height so that dotted border on subscription data is 
   * the same size as the search data */
  $('#subscriptions li').each( function() {
    var li = $(this),
        height = li.find('.search_data').height();
    
    li.find('.subscription_data').height(height);    
  });


  /* unsubscribe */
  $('#subscriptions').delegate('.subscription_data a.unsubscribe', 'click', function(event) {
    event.preventDefault();

    var $link = $(this);

    $.ajax({
      url: $link.attr('href'),
      type: 'DELETE',
      dataType: 'json',

      success: function(response) {
        unsubscribe_success($link, response);
      },
      error: function(error) {
      }
    });
  });

  /* resubscribe */
  $('#subscriptions').delegate('.subscription_data a.resubscribe', 'click', function(event) {
    event.preventDefault();

    var $link = $(this);

    $.ajax({
      url: $link.attr('href'),
      type: 'GET',
      dataType: 'json',

      success: function(response) {
        resubscribe_success($link, response);
      },
      error: function(error) {
      }
    });
  });

});
