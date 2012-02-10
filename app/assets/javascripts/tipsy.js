$(document).ready(function(){
  /* Clippings pages */
  $('.doc_notice.add_tipsy').tipsy(  {gravity: 'e', fallback: "Notice",                delayIn: 100, fade: true, offset: 0});
  $('.doc_rule.add_tipsy').tipsy(    {gravity: 'e', fallback: "Final Rule",            delayIn: 100, fade: true, offset: 0});
  $('.doc_prorule.add_tipsy').tipsy( {gravity: 'e', fallback: "Proposed Rule",         delayIn: 100, fade: true, offset: 0});
  $('.doc_presdocu.add_tipsy').tipsy({gravity: 'e', fallback: "Presidential Document", delayIn: 100, fade: true, offset: 0});

  $('#clippings li div.add_to_folder_pane').tipsy( {gravity: 'w', fallback: "Check to add to a folder", fade: true, offset: 2});
});
