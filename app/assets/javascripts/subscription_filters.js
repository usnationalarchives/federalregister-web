/* global subscription_type_filters:true */

function filter_subscriptions_by_type(el) {
  var doc_type = el.data('filter-doc-type');

  if ( el.hasClass('on') ) {
    el.removeClass('on');
    el.removeClass('hover');

    el.data('tooltip', 'Show ' + el.data('filter-doc-type-display') + ' subscriptions');
    el.tipsy('hide');
    el.tipsy('show');

    var index = _.indexOf(subscription_type_filters, doc_type);
    subscription_type_filters[index] = null;
    subscription_type_filters = _.compact(subscription_type_filters);
  } else {
    el.addClass('on');

    el.data('tooltip', 'Hide ' + el.data('filter-doc-type-display') + ' subscriptions');
    el.tipsy('hide');
    el.tipsy('show');

    subscription_type_filters.push( doc_type );
  }

  var subscriptions_to_hide = _.filter( $('#subscriptions li'), function(subscription) {
                        return ! _.include(subscription_type_filters, $(subscription).data('doc-type') );
                      });

  $('#subscriptions li').show();
  $(subscriptions_to_hide).hide();

}

$(document).ready( function() {

  $('#subscription-type-filter li').each( function() {
    if ( _.include( subscription_type_filters, $(this).data('filter-doc-type') ) ) {
      $(this).addClass('on');
      $(this).data('tooltip', 'Hide ' + $(this).data('filter-doc-type-display') + ' subscriptions' );
    } else {
      $(this).addClass('disabled');
    }
  });

  $('#subscription-type-filter li:not(.disabled)').bind('mouseenter', function(event) {
    $(this).addClass('hover');
  });

  $('#subscription-type-filter li:not(.disabled)').bind('mouseleave', function(event) {
    $(this).removeClass('hover');
  });

  $('#subscription-type-filter li:not(.disabled)').bind('click', function(event) {
    filter_subscriptions_by_type( $(this) );
  });
});

