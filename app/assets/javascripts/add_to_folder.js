function add_items_to_folder(el) {
  var link        = el.find('a');
  var folder_slug = el.data('slug');

  var loader         = link.find('.loader');
  var document_count = link.find('.document_count');
  
  document_count.toggle();
  loader.toggle();

  form = $('form#folder_clippings');
  form_data = form.serializeArray();
  form_data.push( {name: "folder_clippings[folder_slug]", value: folder_slug} );

  $.ajax({
    url: form.prop('action'),
    data: form_data,
    type: "POST"
  }).success( function(response) {
      console.log( 'Response: ', response);

      loader.toggle();
      inner = document_count.find('.document_count_inner');
      inner.html( parseInt(inner.html(), 0) + parseInt(response.folder.doc_count,0) );

      /* update the user add to folder menu with the new counts */
      update_span = $('<span>').addClass('update').html("+" + response.folder.doc_count);
      link.append( update_span );
      update_span.animate({opacity: 1}, 1200);
      
      /* cross fade the update and the count of documents in the folder */
      /* fade out the documents that were moved                         */
      setTimeout(function() {
        update_span.animate({opacity: 0}, 600);
        document_count.css('opacity', 0).show().animate({opacity: 1}, 1200);
        _.each( response.folder.documents, function(doc_id) {
          $("#clippings li[data-doc-id='" + doc_id + "']").animate({opacity: 0}, 600);
        });
      }, 1200);
      
      /* remove the documents that were moved from the dom (after they've faded out */
      setTimeout(function() {
        _.each( response.folder.documents, function(doc_id) {
          $("#clippings li[data-doc-id='" + doc_id + "']").remove();
        });
      }, 1800);
  });

  }

$(document).ready(function() {
  /* save clippings to already created folder */
  $('div#add-to-folder .menu li').live('click', function(event) {
    event.preventDefault();
    add_items_to_folder( $(this) );
  });

});
