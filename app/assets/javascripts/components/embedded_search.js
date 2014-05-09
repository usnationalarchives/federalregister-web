function set_doc_type_search_filter(el) {
  if ( el.hasClass('on') ) {
    el.removeClass('on');
    el.removeClass('hover');

    el.data('tooltip', 'Limit search documents of type ' + el.data('filter-doc-type-display') );
    el.tipsy('hide');
    el.tipsy('show');

    $('#conditions_type_input input#conditions_type_' + el.data('filter-doc-type')).removeAttr('checked');
    $('#conditions_type_input input#conditions_type_' + el.data('filter-doc-type')).trigger('calculate_expected_results');
  } else {
    el.addClass('on');

    el.data('tooltip', 'Remove limitation (documents of type ' + el.data('filter-doc-type-display') + ')' );
    el.tipsy('hide');
    el.tipsy('show');

    $('#conditions_type_input input#conditions_type_' + el.data('filter-doc-type')).attr('checked', true);
    $('#conditions_type_input input#conditions_type_' + el.data('filter-doc-type')).trigger('calculate_expected_results');
  }
}

$(document).ready( function() {
  /* Tipsy for Doctype Filters */
  $('.embedded_search #doc-type-filter li').tipsy( {gravity: 'n', fade: false, offset: 2, title: function() { return $(this).data('tooltip');} });

  /* Tooltips by state */
  $('.embedded_search #doc-type-filter li').each( function() {
    $(this).data('tooltip', 'Limit search to documents of type ' + $(this).data('filter-doc-type-display') );
  });

  $('#conditions_type_input input#conditions_type_' + $('.embedded_search #doc-type-filter li').first().data('filter-doc-type')).trigger('calculate_expected_results');

  $('.embedded_search #doc-type-filter li').bind('mouseenter', function(event) {
    $(this).addClass('hover');
  });

  $('.embedded_search #doc-type-filter li').bind('mouseleave', function(event) {
    $(this).removeClass('hover');
  });

  $('.embedded_search #doc-type-filter li').bind('click', function(event) {
    set_doc_type_search_filter( $(this) );
  });
});

