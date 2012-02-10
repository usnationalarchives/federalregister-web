$(document).ready(function() {
  /* save clippings to already created folder */
  $('div#add-to-folder li').not('#new-folder').click(function() {
    var form = $('form#add-to-folder');
    var form_data = form.serializeArray();
    form_data.push( {name: "folder_clippings[folder_slug]", value: $(this).data('slug')} );

    $.ajax({
      url: form.prop('action'),
      data: $.param( form_data ),
      type: "POST",
      async: false
    });
  });

});
