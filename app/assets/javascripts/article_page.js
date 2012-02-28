/* ajax send document to my_fr2 app and */
/* manage which icons are shown during each process of the ajax action */
function add_item_to_folder(el) {
  el.find('.icon').toggle();
  el.find('.loader').toggle();
  
  form = $('form.add_to_clipboard');
  form_data = form.serializeArray();
  form_data.push( {name: "entry[folder]", value: el.data('slug')} );

  $.ajax({
    url: form.prop('action'),
    data: form_data,
    type: "POST"
  }).success(function(response) {
      /* mark folder as containing document */
      el.removeClass('not_in_folder').addClass('in_folder');

      /* visually mark the icon as in at least one folder */
      /* and increment the document count                 */
      $('div.share li.clip_for_later #add-to-folder .button span.icon').addClass('clipped');
      if ( el.data('slug') == "my-clippings" ) {
        update_user_clipped_document_count(stored_document_numbers);
      } 
      else {
        update_user_folder_document_count(response);
      }
    })
    .complete(function(response) {
      el.find('.loader').toggle();
      el.find('.icon').toggle();
    });
}

/* determine whether to expect a current user */
function expect_logged_in() {
  if ( readCookie('expect_logged_in') == "1" ) {
    return true;
  } else if ( readCookie('expect_logged_in') == "0") {
    return false;
  } else {
    return false;
  }
}

function show_folder_success(response) {
  new_p = $('<p>').append( response.folder.name ).append( $('<span>').addClass('icon') );
  $('#new-folder-modal .folder_success p').replaceWith( new_p );
  $('#new-folder-modal .folder_success').show();
}

function insert_new_folder_into_menu(response) {
  if ( $("#add-to-folder-menu-li-fr2-template") ) {
    template = Handlebars.compile( $("#add-to-folder-menu-li-fr2-template").html() );
    $('#clipping-actions.fr2 #add-to-folder .menu ul')
      .append( $(template(response)).css('opacity', 0)
        .animate({ opacity: 1.0 }, 1500)
      );
  }
}

function update_user_util_folders(response) {
  /* NOTE: currently we do nothing with the response but will in the future */
  update_user_folder_and_document_count(response);
}

function show_clippings_menu() {
  /* turn on hover - these need to be in js or we get weird interactions between js *
  * triggered hovers and css hover states - no one wants a flickering menu         */
  $('#clipping-actions.fr2 #add-to-folder').addClass('hover');
  }
function hide_clippings_menu() {
  $('#clipping-actions.fr2 #add-to-folder').removeClass('hover');
  }

$(document).ready(function () {
  /* hide form and prevent unwanted submission */
  $('form.add_to_clipboard').hide();
  $('form.add_to_clipboard').bind('submit', function(event) {
    event.preventDefault();
  });

  /* update styles on page so that our hover menu is properly viewable */
  if ( $('.metadata_share_bar').length !== 0 ) {
    $('.metadata_share_bar').height( $('.metadata_share_bar .metadata').height() ).css('overflow', 'visible');
  }

  /* get current document */
  current_document_number = $('form.add_to_clipboard input#entry_document_number').val();
  
  
  /*                    *
  *  Add to Folder Menu *
  *                     */

  /* compile template */
  if ( $("#add-to-folder-menu-fr2-template") ) {
    add_to_folder_menu_fr2_template = Handlebars.compile( $("#add-to-folder-menu-fr2-template").html() );
  }
  /* add current document number to the folder details */
  user_folder_details.current_document_number = current_document_number;
  /* place the menu on the page */
  $('div.share li.clip_for_later').append($('<div>').addClass("fr2").prop('id', 'clipping-actions').append( add_to_folder_menu_fr2_template(user_folder_details) ) );
  /* add tipsy to the menu */
  $('#add-to-folder .button.tip_over').tipsy({gravity:'south', live: true});

  /* EVENTS*/
  
  /* show and hide clippings menu */
  $('#clipping-actions').delegate( '#clipping-actions.fr2 #add-to-folder', 'mouseenter', function() {
    show_clippings_menu();
  });
  $('#clipping-actions').delegate( '#clipping-actions.fr2 #add-to-folder', 'mouseleave', function() {
    hide_clippings_menu();
  });
  
  /* allow icon to be clicked as a shortcut for adding current document to the clipboard */
  $('#clipping-actions').delegate( '#clipping-actions.fr2 #add-to-folder .button .icon', 'click', function(event) {
    /* check if already in clipboard */
    not_in_clipboard = $('#clipping-actions.fr2 #add-to-folder .menu li[data-slug="my-clippings"].not_in_folder').length !== 0;
    if ( not_in_clipboard ) {
      $('#clipping-actions.fr2 #add-to-folder .menu li[data-slug="my-clippings"]').trigger('click');
    };
  });


  $('#clipping-actions.fr2 #add-to-folder .menu li').live('click', function(event) { event.preventDefault(); });

  /* enable saving to folder */
  $('#clipping-actions.fr2 #add-to-folder .menu li.not_in_folder').live('click', function(event) {
    event.preventDefault();
    add_item_to_folder( $(this) );
  });

  /* visually identify the document as flagged if its in a folder */
  if( user_folder_details !== undefined && document_number_present(current_document_number, user_folder_details) ) {
    $('div.share li.clip_for_later #add-to-folder .button span.icon').addClass('clipped');
  }


  /*                                 *
  *  Create new folder functionality *
  *                                  */

  $('#add-to-folder .menu li#new-folder').live('click', function(event) {
    event.preventDefault();

    /* disable the hover menu and keep open */
    $('#clipping-actions.fr2').undelegate('#clipping-actions.fr2 #add-to-folder', 'mouseleave');
    $('#clipping-actions.fr2 #add-to-folder').addClass('hover');
    $('#clipping-actions.fr2 div.menu li#new-folder').addClass('hover');
    
    /* decide which modal to show */
    if ( expect_logged_in() ) {
      el = $('#new-folder-modal');
    } else {
      el = $('#account-needed-modal');
    }

    /* show the modal */
    $(el).jqm({
        modal: true,
        toTop: true,
        onShow: myfr2_jqmHandlers.show,
        onHide: myfr2_jqmHandlers.hide
    });
    el.centerScreen().jqmShow();
  });

  $('#new-folder-modal form.folder').live('submit', function(event) {
    event.preventDefault();
    form = $(this);

    /* hide the form so we can show staus messages */
    form.hide();
    form.siblings('p').hide();

    /* show creating folder message and loader */
    $('new-folder-modal .folder_create').show();

    /* submit data and handle response or failure */
    form_data = form.serializeArray();
    form_data.push( {name: "folder[document_numbers]", value: new Array(current_document_number)} );

    $.ajax({
      url: form.prop('action'),
      data: form_data,
      type: "POST"
    }).success(function(response) {
        $('new-folder-modal .folder_create').hide();
        show_folder_success(response); 
        update_user_util_folders(response);

        /* hide the modal about 1 second after success */
        setTimeout(function () {
            $('#new-folder-modal').jqmHide();
            $('#new-folder-modal .folder_success').hide();
            form.siblings('p').show();
            form.find('input#folder_name').val('');
            form.show();
          },
          1200);
        
        /* place the new folder in the flag menu and renable hover functionality */
        setTimeout(function () {
            insert_new_folder_into_menu(response);
            $('div.share li.clip_for_later #add-to-folder .button span.icon').addClass('clipped');
          },
          1225);

        /* return page to a normal state */
        setTimeout(function () {
            /* re-enable our hover menu that was disabled when the 'new folder' button was clicked */
            $('#clipping-actions').delegate( '#clipping-actions.fr2 #add-to-folder', 'mouseleave', function() {
              hide_clippings_menu();
            });
            //
            
            /* close the hover menu */
            hide_clippings_menu();
            $('#clipping-actions.fr2 div.menu li#new-folder').removeClass('hover');
          },
          3700);
      })
      .fail(function(response) {
        $('new-folder-modal .folder_create').hide();
        form.siblings('p').show();
        form.show();
      });

  });


  $("#new-folder-modal .new_folder_close").bind('click', function (event) {
    /* re-enable our hover menu that was disabled when the 'new folder' button was clicked */
    $('#clipping-actions').delegate( '#clipping-actions.fr2 #add-to-folder', 'mouseleave', function() {
      hide_clippings_menu();
    });

    /* close the hover menu */
    hide_clippings_menu();
    $('#clipping-actions.fr2 div.menu li#new-folder').removeClass('hover');
  });    

});
