Handlebars.registerHelper('unlessMyClipboard', function(block) {
  if( this.slug === "my-clippings" ) {
    return block.inverse(this);
  } else {
    return block(this);
  }
});

Handlebars.registerHelper('ifInFolder', function(current_document_number, block) {
  if( _.include(this.documents, current_document_number) ) {
    return block(this);
  } else {
    return block.inverse(this);
  }
});
