function animate_add_to_folder_pane_out(el) {
  el.stop();
  el.animate({
      left: '917px',
      'z-index': 0,
      // height: 'toggle'
    }, {duration: 150, queue: false}
  );
}

function animate_add_to_folder_pane_in(el) {
  el.css('z-index', -100);
  el.stop();
  el.animate({
      left: '879px',
      // height: 'toggle'
    }, {duration: 150, queue: false}
  );
}

function show_clipping_menu( el ) {
  /* turn on hover - these need to be in js or we get weird interactions between js *
  * triggered hovers and css hover states - no one wants a flickering menu         */
  el.addClass('hover');
  }
function hide_clipping_menu( el ) {
  el.removeClass('hover');
  }

$(document).ready(function () {

  /* set the size of the clipping data div to match the size of the 
   * document data div (which we assume is larger) so that we get our
   * nice dashed border seperating the two */
  $('ul#clippings li div.clipping_data').each( function() { 
    $(this).height( $(this).siblings('div.document_data').height() );
  });
  /* also set the size of the add to folder pane and slide it to the left 
   * so that it's hidden */
  $('ul#clippings li div.add_to_folder_pane').each( function() { 
    $(this).height( $(this).closest('ul#clippings li').innerHeight() ).css('left', 879);
    input_el = $(this).find('input').last();
    input_el.css('margin-top', ($(this).height() / 2) - (input_el.height() / 2));
  });

  /* hover in states for add to folder pane */
  $('ul#clippings li').mouseenter(function() {
    var el = $(this).find('div.add_to_folder_pane');
    animate_add_to_folder_pane_out(el);    
  });
  $('ul#clippings li div.add_to_folder_pane').mouseenter(function() {
    animate_add_to_folder_pane_out($(this));    
  });
  /* hover out states for add to folder pane */
  $('ul#clippings li').on('mouseleave', function() {
    var el = $(this).find('div.add_to_folder_pane');
    if( el.find('input.clipping_id').prop('checked') === false ) {
      animate_add_to_folder_pane_in(el);
    }
  });
  $('ul#clippings li div.add_to_folder_pane').on('mouseleave', function() {
    if( $(this).find('input.clipping_id').prop('checked') === false ) {
      animate_add_to_folder_pane_in($(this));
    }
  });

  /* Add/Jump to Folder Menu */
  if ( $("#add-to-folder-menu-template") ) {
    add_to_folder_menu_template = Handlebars.compile( $("#add-to-folder-menu-template").html() );
  }
  $('#clipping-actions').prepend( add_to_folder_menu_template(user_folder_details) );
  if ( $("#jump-to-folder-menu-template") ) {
    jump_to_folder_menu_template = Handlebars.compile( $("#jump-to-folder-menu-template").html() );
  }
  $('#clipping-actions').prepend( jump_to_folder_menu_template(user_folder_details) );
  
  

  /* show and hide add_to_folder menu */
  $('#clipping-actions').delegate( '#clipping-actions #add-to-folder, #clipping-actions #jump-to-folder', 'mouseenter', function() {
    show_clipping_menu( $(this) );
  });
  /* the hides need to be delegating seperating so that we can unbind them individually */
  /* currently used for creating a new folder */
  $('#clipping-actions').delegate( '#clipping-actions #add-to-folder', 'mouseleave', function() {
    hide_clipping_menu( $(this) );
  });
  $('#clipping-actions').delegate( '#clipping-actions #jump-to-folder', 'mouseleave', function() {
    hide_clipping_menu( $(this) );
  });

  /* remove clipping */
  $('#clipping-actions').delegate('#remove-clipping', 'click', function(event) {
    
    clipping_ids = _.map( $('form#folder_clippings input:checked'), function(input) { 
                      return $(input).closest('li').data('doc-id'); 
                   });
  
    current_folder_slug = $('div.title').data('folder-slug');
    
    form = $('form#folder_clippings');
    form_data = form.serializeArray();
    form_data.push( {name: "folder_clippings[clipping_ids]", value: clipping_ids} );
    form_data.push( {name: "folder_clippings[folder_slug]", value: current_folder_slug} );

    $.ajax({
      url: '/my/folder_clippings/delete',
      data: form_data,
      type: "POST"
    }).success( function(response) {
        _.each( response.folder.documents, function(doc_id) {
          $("#clippings li[data-doc-id='" + doc_id + "']").animate({opacity: 0}, 600);
        });

        setTimeout(function() {
            _.each( response.folder.documents, function(doc_id) {
              $("#clippings li[data-doc-id='" + doc_id + "']").remove();
            });
  
            update_clippings_on_page_count( response.folder.doc_count );
            update_add_folder_count( response, 'remove' );
            update_jump_folder_count( response, 'remove' );
            update_user_util_counts( response.folder.doc_count, response.folder.slug, false );
          }, 
          600);
      });
  });
});
