$(document).ready(function(){
  /* Clippings pages */
  $('.doc_notice.add_tipsy').tipsy(  {gravity: 'e', fallback: "Notice",                delayIn: 100, fade: true, offset: 0});
  $('.doc_rule.add_tipsy').tipsy(    {gravity: 'e', fallback: "Final Rule",            delayIn: 100, fade: true, offset: 0});
  $('.doc_prorule.add_tipsy').tipsy( {gravity: 'e', fallback: "Proposed Rule",         delayIn: 100, fade: true, offset: 0});
  $('.doc_presdocu.add_tipsy').tipsy({gravity: 'e', fallback: "Presidential Document", delayIn: 100, fade: true, offset: 0});

  /* slide out drawers */
  $('#clippings li div.add_to_folder_pane').tipsy( {gravity: 'w', fallback: "Select clipping(s) and modify using menus above", fade: true, offset: -8});
  
  /* clipping actions */
  $('#clipping-actions #add-to-folder').tipsy( {gravity: 's', fallback: "Select clipping(s) below to move them", fade: true, offset: 2});
  $('#clipping-actions #remove-clipping').tipsy( {gravity: 's', fallback: "Delete selected clipping(s)", fade: true, offset: 2});

});
