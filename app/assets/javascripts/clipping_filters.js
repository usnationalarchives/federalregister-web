String.prototype.capitalize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1);
}

function filter_clippings_by_type(el) {
  var doc_type = el.data('filter-doc-type');

  if ( el.hasClass('on') ) {
    el.removeClass('on');
    el.removeClass('hover');

    el.data('tooltip', 'Show documents of type ' + el.data('filter-doc-type-display') );
    el.tipsy('hide');
    el.tipsy('show');

    index = _.indexOf(doc_type_filters, doc_type);
    doc_type_filters[index] = null;
    doc_type_filters = _.compact(doc_type_filters);
  } else {
    el.addClass('on');

    el.data('tooltip', 'Hide documents of type ' + el.data('filter-doc-type-display') );
    el.tipsy('hide');
    el.tipsy('show');

    doc_type_filters.push( doc_type );
  }

  documents_to_hide = _.filter( $('#clippings li'), function(clipping) {
                        return ! _.include(doc_type_filters, $(clipping).data('doc-type') );
                      });

  $('#clippings li').show();
  $(documents_to_hide).hide();
  
}

$(document).ready( function() {

  if( $('#clipping-actions #doc-type-filter').length > 0 ) {
    $('#doc-type-filter li').each( function() {
        if ( _.include( doc_type_filters, $(this).data('filter-doc-type') ) ) {
        $(this).addClass('on');
        $(this).data('tooltip', 'Hide articles of type ' + $(this).data('filter-doc-type-display') );
      } else {
        $(this).addClass('disabled');
      }
    });

    $('#doc-type-filter li:not(.disabled)').bind('mouseenter', function(event) {
      $(this).addClass('hover');
    });

    $('#doc-type-filter li:not(.disabled)').bind('mouseleave', function(event) {
      $(this).removeClass('hover');
    });

    $('#doc-type-filter li:not(.disabled)').bind('click', function(event) {
      filter_clippings_by_type( $(this) );
    });
  }

});
