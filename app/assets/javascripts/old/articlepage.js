$(document).ready(function () {
  var citation_modal_template;
  if ( $("#select-cfr-citation-template").length > 0 ) {
    citation_modal_template = Handlebars.compile($("#select-cfr-citation-template").html());
  }

  function closeOnEscape(hash) {
    $(window).one('keyup', function(event) {
      if( event.keyCode === '27' ){
        hash.w.jqmHide();
      }
    });
  }

  function display_cfr_modal(title, html) {
    if ($('#cfr_citation_modal').length === 0) {
        $('body').append('<div id="cfr_citation_modal"/>');
    }
    $('#cfr_citation_modal').html(
      [
      '<a href="#" class="jqmClose">Close</a>',
      '<h3 class="title_bar">' + title + '</h3>',
      html
      ].join("\n")
    );
    $('#cfr_citation_modal').jqm({
        modal: true,
        onShow: function(hash) {
                  closeOnEscape(hash);
                  hash.w.show();
                }
    });
    $('#cfr_citation_modal').jqmShow().centerScreen();
  }


  // cfr citation modal
  $('a.cfr.external').bind('click', function(event) {
    var link = $(this);
    var cfr_url = link.attr('href');

    if( cfr_url.match(/^\//) ) {
      event.preventDefault();

      $.ajax({
        url: cfr_url,
        dataType: 'json',
        success: function(response) {
          var cfr_html = citation_modal_template(response);
          display_cfr_modal('External CFR Selection', cfr_html);
        }
      });
    }
  });
});
