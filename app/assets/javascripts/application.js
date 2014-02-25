//= require jquery_ujs
//= require bootstrap/dropdown
//= require jquery.clippy.min
//= require_self
//= require add_to_folder
//= require clippings
//= require clipping_filters
//= require subscription_filters
//= require tipsy
//= require article_page
//= require document_page
//= require utility_bar

$(document).ready(function() {
  $('.clippy').clippy({
    keep_text: true,
    clippy_path: '/assets/clippy.swf'
  });
});
