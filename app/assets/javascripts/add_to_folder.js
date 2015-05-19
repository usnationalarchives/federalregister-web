function update_clippings_on_page_count(count) {
  count_span = $('#folder_metadata_bar span.clippings_on_page_count');
  current_count = parseInt( count_span.html(), 0 );
  count_span.html( current_count - count);
  }
function update_current_folder_page_counts( count ) {
  current_folder_slug = $('h2.title').data('folder-slug');
  jump_to_folder_inner   = $('#jump-to-folder .menu li[data-slug="' + current_folder_slug + '"] .document_count_inner');
  add_to_folder_inner    = $('#add-to-folder .menu li[data-slug="' + current_folder_slug + '"] .document_count_inner');
  
  jump_to_folder_inner.html( parseInt(jump_to_folder_inner.html(), 0) - count );
  add_to_folder_inner.html( parseInt(add_to_folder_inner.html(), 0) - count );
  }
function update_add_folder_count( response, action ) {
  add_to_folder_inner = $('#add-to-folder .menu li[data-slug="' + response.folder.slug + '"] .document_count_inner');
  if ( action === undefined || action === 'add' ) {
    add_to_folder_inner.html( parseInt(add_to_folder_inner.html(), 0) + response.folder.doc_count );
  }
  else if ( action === 'remove' ) {
    add_to_folder_inner.html( parseInt(add_to_folder_inner.html(), 0) - response.folder.doc_count );
  }
}
function update_jump_folder_count( response, action ) {
  jump_to_folder_inner = $('#jump-to-folder .menu li[data-slug="' + response.folder.slug + '"] .document_count_inner');
  if ( action === undefined || action === 'add' ) {
    jump_to_folder_inner.html( parseInt(jump_to_folder_inner.html(), 0) + response.folder.doc_count );
  }
  else if ( action === 'remove' ) {
    jump_to_folder_inner.html( parseInt(jump_to_folder_inner.html(), 0) - response.folder.doc_count );
  }
}
function update_user_util_counts( count, slug, new_folder, action ) {
  holder = $('#user_utils #document-count-holder');
  current_folder_slug = $('h2.title').data('folder-slug');

  /* we're moving documents from the clipboard to another folder */
  if ( current_folder_slug === "my-clippings" ) {
    /* decrement the count of items in the clipboard */
    document_count = holder.find('#doc_count');
    document_count.html( parseInt(document_count.html(), 0) - count );
    /* increment folder counts */
    if ( new_folder ) {
      folder_count = holder.find('#user_folder_count');
      folder_count.html( parseInt(folder_count.html(), 0) + 1);
    } 
    if ( action !== 'delete' ) {
      /* increase documents in folders count */
      documents_in_folders = holder.find('#user_documents_in_folders_count');
      documents_in_folders.html( parseInt(documents_in_folders.html(), 0) + count );
    }
  } 
  else {
    /* we're moving items from a folder to the clipboard */
    if ( slug === "my-clippings" ) {
      if ( action !== 'delete' ) {
        /* increment the count of items in the clipboard */
        document_count = holder.find('#doc_count');
        document_count.html( parseInt(document_count.html(), 0) + count );
      }
      /* decrease documents in folders count */
      documents_in_folders = holder.find('#user_documents_in_folders_count');
      documents_in_folders.html( parseInt(documents_in_folders.html(), 0) - count );
    }
    /* there are no counts to change if we're moving items between folders */

    /* remove documents from folder counts if we're deleting */
    if ( action === 'delete' ) {
      documents_in_folders = holder.find('#user_documents_in_folders_count');
      documents_in_folders.html( parseInt(documents_in_folders.html(), 0) - count );
    }
  }
}
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

        update_clippings_on_page_count( response.folder.doc_count );
        update_current_folder_page_counts( response.folder.doc_count );
        update_jump_folder_count( response );
        update_user_util_counts( response.folder.doc_count, response.folder.slug, false );
      }, 1800);
  });

}

function insert_new_folders_into_clipping_menus(response) {
  if ( $("#add-to-folder-menu-li-template").length === 1 ) {
    /* generate new folder li and append */
    template = Handlebars.compile( $("#add-to-folder-menu-li-template").html() );
    new_folder_li = $(template(response));
    new_jump_to_folder_li = new_folder_li.clone();

    new_folder_li.css('opacity', 0);
    $('#clipping-actions #add-to-folder .menu ul').append( new_folder_li );

    new_jump_to_folder_li.find('a').attr('href', "/my/folders/"+response.folder.slug);
    $('#clipping-actions #jump-to-folder .menu ul').append( new_jump_to_folder_li );
    
    /* toggle the document count and place the update span in its place */
    link = new_folder_li.find('a');
    document_count = link.find('.document_count');
    document_count.toggle();
    
    update_span = $('<span>').addClass('update').html("+" + response.folder.doc_count).css('opacity', 1);
    link.append( update_span );

    /* fade in the new folder li */
    new_folder_li.animate({opacity: 1}, 1200);

    /* cross fade the update and the count of documents in the folder */
    setTimeout(function () {
      update_span.animate({opacity: 0}, 600);
      document_count.css('opacity', 0).show().animate({opacity: 1}, 1200);
    }, 1500);
  }
}

function create_new_folder_with_items( form, clipping_ids ) {
  /* hide the form so we can show status messages */
  form.hide();
  form.siblings('p').hide();
  $('#new-folder-modal .folder_error').hide();

  /* show creating folder message and loader */
  $('new-folder-modal .folder_create').show();

  /* submit data and handle response or failure */
  form_data = form.serializeArray();
  form_data.push( {name: "folder[clipping_ids]", value: clipping_ids} );

  $.ajax({
      url: form.prop('action'),
      data: form_data,
      type: "POST"
    }).success(function(response) {
        $('new-folder-modal .folder_create').hide();
        show_folder_success(response);

        /* hide the modal about 1 second after success */
        setTimeout(function () {
            $('#new-folder-modal').jqmHide();
            $('#new-folder-modal .folder_success').hide();
            form.siblings('p').show();
            form.find('input#folder_name').val('');
            form.show();
          },
          800);
        
        setTimeout(function() {
            /* insert the newly created folder */
            insert_new_folders_into_clipping_menus(response);
          },
          1025);

        setTimeout(function() {
            /* remove from the current view the clippings that were added to the new folder */
            _.each( response.folder.documents, function(doc_id) {
              $("#clippings li[data-doc-id='" + doc_id + "']").animate({opacity: 0}, 600);
            });
          },
          3725);

        /* remove the documents that were moved from the dom (after they've faded out */
        setTimeout(function() {
            _.each( response.folder.documents, function(doc_id) {
              $("#clippings li[data-doc-id='" + doc_id + "']").remove();
            });
            
            update_clippings_on_page_count( response.folder.doc_count );
            update_current_folder_page_counts( response.folder.doc_count );
            update_user_util_counts( response.folder.doc_count, response.folder.slug, true );
          },
          4325);

        /* close the menu and return page state to normal once the new folder animation is complete */
        setTimeout(function() {
            $('#clipping-actions').on('mouseleave', '#add-to-folder', function() {
              hide_clipping_menu( $(this) );
            });
            $('#clipping-actions #add-to-folder').removeClass('hover');
            $('#clipping-actions div.menu li#new-folder').removeClass('hover');


            hide_clipping_menu( $('#clipping-actions #add-to-folder') );
          },
          4725);
      })
      .fail( function(response) {
        $('new-folder-modal .folder_create').hide();
      
        responseText = $.parseJSON( response.responseText);
        $('#new-folder-modal .folder_error p .message').html(responseText.errors[0]);
        $('#new-folder-modal .folder_error').show();

        form.siblings('p').show();
        form.show();
      });
}

$(document).ready(function() {
  /* save clippings to already created folder */
  $('div#add-to-folder .menu li:not(#new-folder)').live('click', function(event) {
    event.preventDefault();
    current_folder_slug = $('h2.title').data('folder-slug');
    if ( $('form#folder_clippings input:checked').length !== 0 && $(this).data('slug') !== current_folder_slug) {
      add_items_to_folder( $(this) );
    }
  });

  /* new folder creation */
  $('#add-to-folder .menu li#new-folder').live('click', function(event) {
    event.preventDefault();
    
    /* disable the hover menu and keep open */
    $('#clipping-actions').off('mouseleave', '#add-to-folder');
    $('#clipping-actions #add-to-folder').addClass('hover');
    $('#clipping-actions div.menu li#new-folder').addClass('hover');

    /* decide which modal to show */
    if ( expect_logged_in() ) {
      if ( $('#new-folder-modal-template').length === 1 ) {
        modal_template = Handlebars.compile( $("#new-folder-modal-template").html() );
        modal = $( modal_template({}) );
        if ( $('#new-folder-modal') ) {
          $('#new-folder-modal').remove();
        }
        $('body').append( modal );
      }
    } else {
      if ( $('#account-needed-modal-template').length === 1 ) {
        modal_template = Handlebars.compile( $("#account-needed-modal-template").html() );
        modal = $( modal_template({}) );
        if ( $('#account-needed-modal') ) {
          $('#account-needed-modal').remove();
        }
        $('body').append( modal );
      }
    }
    
    if ( modal.is('#new-folder-modal') ) {
      var selected_clipping_count = $('form#folder_clippings .add_to_folder_pane input.clipping_id:checked').length,
          text = "";

      if( selected_clipping_count > 0 ) {
        text = "When this folder is created the <strong>" + selected_clipping_count + " selected " + (selected_clipping_count === 1 ? 'clipping' : 'clippings') + "</strong> will be moved to it.";
      }

      modal.find('p.instructions span#fyi').html(text);
    }
  
    /* attach events to the modal close */
    modal.find(".jqmClose").bind('click', function (event) {
      menu = $('#clipping-actions #add-to-folder');

      /* re-enable our hover menu that was disabled when the 'new folder' button was clicked */
      menu.bind('mouseleave', function() {
        hide_clipping_menu( $(this) );
      });

      /* close the hover menu */
      hide_clipping_menu( menu );
      menu.removeClass('hover');
      menu.find('.menu li#new-folder').removeClass('hover');
    });

    /* show the modal */
    $(modal).jqm({
        modal: true,
        toTop: true,
        onShow: myfr2_jqmHandlers.show,
        onHide: myfr2_jqmHandlers.hide
    });
    modal.jqmShow().centerScreen();
  });

  // delete a folder
  $('#delete-folder').on('click', function(event){
    event.preventDefault();
    var folderData = {
          numClippings: $('#clippings li').size(),
          folderSlug: $('h2.title').data().folderSlug
    };
    var modalTemplateScript = $("#folder-delete-modal-template").html();
    var handlebarsModal = Handlebars.compile (modalTemplateScript);
    $(document.body).append (handlebarsModal (folderData));
    $('#confirm-folder-delete-modal').jqm({
        modal: true,
        toTop: true,
        onShow: myfr2_jqmHandlers.show,
        onHide: myfr2_jqmHandlers.hide
    });
    $('#confirm-folder-delete-modal').jqmShow().centerScreen();
  });

  $('#new-folder-modal form.folder').live('submit', function(event) {
    event.preventDefault();

    clipping_ids = _.map( $('form#folder_clippings .add_to_folder_pane input.clipping_id:checked'), function(input) { 
                      return $(input).closest('li').data('doc-id'); 
                   });
    create_new_folder_with_items( $(this), clipping_ids );
  });

});
