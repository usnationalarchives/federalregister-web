function display_fr_modal(title, html, el, options) {
      var modalOptions = options === undefined ? {} : options;

      var fr_modal = $('#fr_modal');
      fr_modal.remove();
      fr_modal = $('<div id="fr_modal"/>');

      fr_modal.html(
        [
        '<a href="#" class="jqmClose">Close</a>',
        '<h3 class="title_bar">' + title + '</h3>',
        html
        ].join("\n")
      );

      if( modalOptions.modalClass !== undefined ) {
        fr_modal.addClass(options.modalClass);
      }
      fr_modal.addClass('jqmWindow');

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

      $('body').on('click', '#fr_modal a.jqmClose', function(e) {
        $('#fr_modal').jqmHide();
      });

      fr_modal.jqmShow().centerScreen();
  }

$(document).ready(function() {

  $('#main').on('click', 'a.fr_modal, a.fr_modal_link', function (event) {
      event.preventDefault();

      var $link = $(this);

      var modal_title    = $link.data('modal-title'),
          modal_template = $("#" + $link.data('modal-template-name')),
          modal_data     = $link.data('modal-data');

      /* ensure template exists on page */
      var modal_html;
      if ( modal_template.length > 0 ) {
        var compiled_template = Handlebars.compile( modal_template.html() );
        modal_html = compiled_template( modal_data );
      } else {
        modal_html = $link.data('modal-html');
      }

      $('body').on('click', '#fr_modal a.jqmClose', function(e) {
        $('#fr_modal').jqmHide();
      });

      display_fr_modal(modal_title, modal_html, $link);
  });

});
