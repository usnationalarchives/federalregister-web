function update_clippings_on_page_count(count) {
  var count_span, current_count;

  count_span = $('#folder_metadata_bar span.clippings_on_page_count');
  current_count = parseInt( count_span.html(), 0 );
  count_span.html( current_count - count);
}

function update_current_folder_page_counts( count ) {
  var current_folder_slug, jump_to_folder_inner, add_to_folder_inner;

  current_folder_slug = $('h2.title').data('folder-slug');
  jump_to_folder_inner   = $('#jump-to-folder .menu li[data-slug="' + current_folder_slug + '"] .document_count_inner');
  add_to_folder_inner    = $('#add-to-folder .menu li[data-slug="' + current_folder_slug + '"] .document_count_inner');

  jump_to_folder_inner.html( parseInt(jump_to_folder_inner.html(), 0) - count );
  add_to_folder_inner.html( parseInt(add_to_folder_inner.html(), 0) - count );
}

function update_add_folder_count( response, action ) {
  var add_to_folder_inner;

  add_to_folder_inner = $('#add-to-folder .menu li[data-slug="' + response.folder.slug + '"] .document_count_inner');
  if ( action === undefined || action === 'add' ) {
    add_to_folder_inner.html( parseInt(add_to_folder_inner.html(), 0) + response.folder.doc_count );
  }
  else if ( action === 'remove' ) {
    add_to_folder_inner.html( parseInt(add_to_folder_inner.html(), 0) - response.folder.doc_count );
  }
}

function update_jump_folder_count( response, action ) {
  var jump_to_folder_inner;

  jump_to_folder_inner = $('#jump-to-folder .menu li[data-slug="' + response.folder.slug + '"] .document_count_inner');
  if ( action === undefined || action === 'add' ) {
    jump_to_folder_inner.html( parseInt(jump_to_folder_inner.html(), 0) + response.folder.doc_count );
  }
  else if ( action === 'remove' ) {
    jump_to_folder_inner.html( parseInt(jump_to_folder_inner.html(), 0) - response.folder.doc_count );
  }
}

function update_user_util_counts( count, slug, new_folder, action ) {
  var holder, current_folder_slug, document_count, folder_count, documents_in_folders;

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
