$(document).ready(function(){
  /* Clippings pages */
  $('.doc_notice.add_tipsy').tipsy(  {gravity: 'e', fallback: "Notice",                delayIn: 100, fade: true, offset: 0});
  $('.doc_rule.add_tipsy').tipsy(    {gravity: 'e', fallback: "Final Rule",            delayIn: 100, fade: true, offset: 0});
  $('.doc_proposed_rule.add_tipsy').tipsy( {gravity: 'e', fallback: "Proposed Rule",         delayIn: 100, fade: true, offset: 0});
  $('.doc_presidential_document.add_tipsy').tipsy({gravity: 'e', fallback: "Presidential Document", delayIn: 100, fade: true, offset: 0});
  $('.doc_unknown.add_tipsy').tipsy( {gravity: 'e', fallback: "Document of Unknown Type", delayIn: 100, fade: true, offset: 0});
  $('.doc_uncategorized.add_tipsy').tipsy( {gravity: 'e', fallback: "Uncategorized Document", delayIn: 100, fade: true, offset: 0});
  $('.doc_correct.add_tipsy').tipsy( {gravity: 'e', fallback: "Correction",               delayIn: 100, fade: true, offset: 0});

  /* checkbox drawers */
  $('#clippings li div.add_to_folder_pane').tipsy( {gravity: 'e', fallback: "Select clipping(s) and modify using menus above", fade: true, offset: -15});
  
  /* clipping actions */
  $('#clipping-actions #add-to-folder').tipsy( {gravity: 's', fallback: "Select clipping(s) below to move them", fade: true, offset: 2});
  $('#clipping-actions #remove-clipping').tipsy( {gravity: 's', fallback: "Delete selected clipping(s)", fade: true, offset: 2});

  /* Doctype Filters */
  $('#clipping-actions #doc-type-filter li:not(.disabled)').tipsy( {gravity: 's', fade: false, offset: 2, title: function() { return $(this).data('tooltip');} });
  $('#doc-type-filter li:not(.disabled)').tipsy( {gravity: 's', fade: true, offset: 2, title: function() { return $(this).data('tooltip');} });
  /* Subscription Filters */
  $('#subscription-type-filter li:not(.disabled)').tipsy( {gravity: 's', fade: true, offset: 2, title: function() { return $(this).data('tooltip');} });

  $('.clipping_data .comment_on').tipsy( {gravity: 's', fade: true, offset: 3, fallback: 'You have officially commented on this article.'} );

  $('#comments .comment_count').tipsy( {gravity: 's', delayIn: 500, fade: true, offset: 3, title: function() { return $(this).data('tooltip');} });
  /*** Comment form tipsy is defined in comment.js.erb ***/
});
