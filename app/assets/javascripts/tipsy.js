$(document).ready(function(){
  /* Clippings pages */
  $('.doc_notice.add_tipsy').tipsy(  {gravity: 'e', fallback: "Notice",                delayIn: 100, fade: true, offset: 0});
  $('.doc_rule.add_tipsy').tipsy(    {gravity: 'e', fallback: "Final Rule",            delayIn: 100, fade: true, offset: 0});
  $('.doc_proposed_rule.add_tipsy').tipsy( {gravity: 'e', fallback: "Proposed Rule",         delayIn: 100, fade: true, offset: 0});
  $('.doc_presidential_document.add_tipsy').tipsy({gravity: 'e', fallback: "Presidential Document", delayIn: 100, fade: true, offset: 0});
  $('.doc_unknown.add_tipsy').tipsy( {gravity: 'e', fallback: "Document of Unknown Type", delayIn: 100, fade: true, offset: 0});
  $('.doc_uncategorized.add_tipsy').tipsy( {gravity: 'e', fallback: "Uncategorized Document", delayIn: 100, fade: true, offset: 0});
  $('.doc_correct.add_tipsy').tipsy( {gravity: 'e', fallback: "Correction",               delayIn: 100, fade: true, offset: 0});

  /* home page - officialness */
  /* popular documents */
  $('.fr-list .rule_type.with-tooltip-e').tipsy({
    gravity: 'e',
    delayIn: 100,
    fade: true,
    offset: 4,
    title: function() { return $(this).data('tooltip');}
  });
  $('.fr-list .rule_type.with-tooltip-s').tipsy({
    gravity: 's',
    delayIn: 100,
    fade: true,
    offset: 4,
    title: function() { return $(this).data('tooltip');}
  });

  $('.fr-list .fr-link-stats li.with-tooltip').tipsy({
    gravity: 'e',
    delayIn: 100,
    fade: true,
    offset: 4,
    title: function() { return $(this).data('tooltip');}
  });

  /* browse agencies/topics */
  $('.fr-table .with-tooltip-s').tipsy({
    gravity: 's',
    delayIn: 100,
    fade: true,
    offset: 4,
    title: function() { return $(this).data('tooltip');}
  });

  /* checkbox drawers */
  $('#clippings li div.add_to_folder_pane').tipsy( {gravity: 'e', fallback: "Select clipping(s) and modify using menus above", fade: true, offset: -15});

  /* clipping actions */
  $('#clipping-actions #add-to-folder').tipsy( {gravity: 's', fallback: "Select clipping(s) below to move them", fade: true, offset: 2});
  $('#clipping-actions #remove-clipping').tipsy( {gravity: 's', fallback: "Delete selected clipping(s)", fade: true, offset: 2});

  /* Doctype Filters */
  $('#clipping-actions #doc-type-filter li:not(.disabled)').tipsy( {gravity: 's', fade: false, offset: 2, title: function() { return $(this).data('tooltip');} });

  /* Subscription Filters */
  $('#subscription-type-filter li:not(.disabled)').tipsy( {gravity: 's', fade: true, offset: 2, title: function() { return $(this).data('tooltip');} });

  $('.clipping_data .comment_on').tipsy( {gravity: 's', fade: true, offset: 3, fallback: 'You have officially commented on this document.'} );

  $('#comments .comment_count').tipsy({
    gravity: 's',
    delayIn: 500,
    fade: true,
    offset: 3,
    title: function() { return $(this).data('tooltip'); }
  });
  /*** Comment form tipsy is defined in comment.js.erb ***/
});
