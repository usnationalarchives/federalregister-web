function display_fr_modal(title, html) {
      if ($('#fr_modal').size() === 0) {
          $('body').append('<div id="fr_modal"/>');
      }
      $('#fr_modal').html(
        [
        '<a href="#" class="jqmClose">Close</a>',
        '<h3 class="title_bar">' + title + '</h3>',
        html
        ].join("\n")
      );
      $('#fr_modal').jqm({
          modal: true,
          toTop: true,
          onShow: this.modalOpen
      });
      $('#fr_modal').centerScreen().jqmShow();
  }

$(document).ready(function() {

  $('a.fr_modal').live('click', function (event) {
      event.preventDefault();
      
      var modal_title    = $(this).data('modal-title'),
          modal_template = $("#" + $(this).data('modal-template-name'));

      /* ensure template exists on page */
      if ( modal_template.length > 0 ) {
        modal_html = Handlebars.compile( modal_template.html() );
      } else {
        modal_html = $(this).data('modal-html');
      }

      display_fr_modal(modal_title, modal_html);
  });
 
});
