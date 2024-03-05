function unsubscribe_success($link, response) {
  $link.removeClass('unsubscribe').addClass('resubscribe').html('re-activate');
  $link.siblings('span.active').removeClass('active').addClass('inactive').html('inactive');
  $link.attr('href', response.resubscribe_url);
}

function resubscribe_success($link, response) {
  $link.removeClass('resubscribe').addClass('unsubscribe').html('suspend');
  $link.siblings('span.inactive').removeClass('inactive').addClass('active').html('active');
  $link.attr('href', response.unsubscribe_url);
}

function destroy_subscription_success($link, response) {
  $('.fr-modal').jqmHide();
  var subscriptionId = $link.data('subscription-id');
  var subscriptionDiv = $("ul.subscriptions").find("[data-subscription-id='" + subscriptionId + "']");
  subscriptionDiv.hide();


  if (response.publicInspectionDocument) {
    var piDocCount = $('.pi-doc-count-js').text();
    $('.pi-doc-count-js').text(piDocCount - 1);
  } else {
    var docCount = $('.doc-count-js').text();
    $('.doc-count-js').text(docCount - 1);
  }
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
      type: 'GET',
      dataType: 'json',

      success: function(response) {
        unsubscribe_success($link, response);
      },
      error: function() {
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
      error: function() {
      }
    });
  });


  /* delete */
  $('#subscriptions').delegate('.subscription_data a.confirm-subscription-destroy-js', 'click', function(event) {
    event.preventDefault();

    var $link = $(this);

    var anchorTag = "<a data-subscription-id='" + $link.data('subscription-id') + "' class='fr_button medium primary destroy-js' href='" + $link.attr('href') + "'>Delete</a>";

    FR2.Modal.displayModal(
      'Please Confirm Deletion',
      "<p>Are you sure you would like to delete this subscription? This can not be undone.</p>" + anchorTag
    );
  });

  $("#subscriptions").on( "click", "a.destroy-js", function( event ) {
    event.preventDefault();
    var $link = $(this);

    $.ajax({
      url: $link.attr('href'),
      type: 'DELETE',
      dataType: 'json',
      success: function(response) {
        destroy_subscription_success($link, response);
      },
      error: function() {
      }
    });
  });

});
