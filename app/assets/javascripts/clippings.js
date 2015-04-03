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
    $(this).height( $(this).closest('ul#clippings li').innerHeight() );
    var input_el = $(this).find('input').last();
    input_el.css('margin-top', ($(this).height() / 2) - (input_el.height() / 2));
  });

  /* Add/Jump to Folder Menu */
  if ( $("#add-to-folder-menu-template").length > 0 ) {
    var add_to_folder_menu_template = Handlebars.compile( $("#add-to-folder-menu-template").html() );

    $( add_to_folder_menu_template(user_folder_details) ).insertAfter( '#clipping-actions #doc-type-filter' );
  }
  if ( $("#jump-to-folder-menu-template").length > 0 ) {
    var jump_to_folder_menu_template = Handlebars.compile( $("#jump-to-folder-menu-template").html() );

    $( jump_to_folder_menu_template(user_folder_details) ).insertAfter('#clipping-actions #doc-type-filter');
  }


  /* show and hide add_to_folder menu */
  $('#clipping-actions').on('mouseenter', '#add-to-folder, #jump-to-folder', function() {
    show_clipping_menu( $(this) );
  });
  /* the hides need to be delegating seperating so that we can unbind them individually */
  /* currently used for creating a new folder */
  $('#clipping-actions').on('mouseleave', '#add-to-folder', function() {
    hide_clipping_menu( $(this) );
  });
  $('#clipping-actions').on('mouseleave', '#jump-to-folder', function() {
    hide_clipping_menu( $(this) );
  });

  /* remove clipping */
  $('#clipping-actions').on('click', '#remove-clipping', function(event) {

    var clipping_ids = _.map( $('form#folder_clippings input:checked'), function(input) {
                      return $(input).closest('li').data('doc-id');
                   });

    var current_folder_slug = $('h2.title').data('folder-slug');

    var form, form_data;
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
            update_user_util_counts( response.folder.doc_count, response.folder.slug, false, 'delete' );
          },
          600);
      });
  });
});
