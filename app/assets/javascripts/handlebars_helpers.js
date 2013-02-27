Handlebars.registerHelper('unlessMyClipboard', function(block) {
  if( this.slug === "my-clippings" ) {
    return block.inverse(this);
  } else {
    return block.fn(this);
  }
});

Handlebars.registerHelper('ifInFolder', function(current_document_number, block) {
  if( _.include(this.documents, current_document_number) ) {
    return block.fn(this);
  } else {
    return block.inverse(this);
  }
});

Handlebars.registerHelper('truncate_words', function(text, word_count) {
  return new Handlebars.SafeString( text.split(" ").splice(0,word_count).join(" ") + "..." );
});

Handlebars.registerHelper('date_in_past', function(date, block) {
  if( new Date(date) > new Date() ) {
    return block.fn(this);
  } else {
    return block.inverse(this);
  }
});

Handlebars.registerHelper('formatted_date', function(date) {
  return strftime('%m/%d/%Y', new Date(date));
});

Handlebars.registerHelper('pluralize', function(number, single, plural) {
  if( number === 1 ) { 
    return single;
  } else { 
    return plural;
  }
});
