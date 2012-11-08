function display_fr_modal(title, html, el) {
      var fr_modal = $('#fr_modal');
      if (fr_modal.size() === 0) {
          $('body').append('<div id="fr_modal"/>');
      }
      fr_modal.html(
        [
        '<a href="#" class="jqmClose">Close</a>',
        '<h3 class="title_bar">' + title + '</h3>',
        html
        ].join("\n")
      );

      var closeModal = function(hash) { 
        el.trigger('modalClose');
        hash.w.remove();
        hash.o.remove();
      };

      fr_modal.jqm({
          modal: true,
          toTop: true,
          onShow: this.modalOpen,
          onHide: closeModal
      });
      
      fr_modal.centerScreen().jqmShow();
  }

$(document).ready(function() {

  $('a.fr_modal').live('click', function (event) {
      event.preventDefault();
      
      var $link = $(this);

      var modal_title    = $link.data('modal-title'),
          modal_template = $("#" + $link.data('modal-template-name')),
          modal_data     = $link.data('modal-data');

      /* ensure template exists on page */
      if ( modal_template.length > 0 ) {
        compiled_template = Handlebars.compile( modal_template.html() );
        modal_html = compiled_template( modal_data );
      } else {
        modal_html = $link.data('modal-html');
      }

      display_fr_modal(modal_title, modal_html, $link);
  });
 
});
