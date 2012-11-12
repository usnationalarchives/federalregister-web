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

Handlebars.registerHelper('human_size', function(bytes) {
  if (typeof bytes !== 'number') {
    return '';
  }
  if (bytes >= 1000000) {
    return (bytes / 1000000).toFixed(2) + ' MB';
  }
  return (bytes / 1000).toFixed(2) + ' KB';
});

Handlebars.registerHelper('localize', function(str) {
  var messages =  {
    "maxFileSize": "File is too big",
    "minFileSize": "File is too small",
    "acceptFileTypes": "File type not allowed",
    "maxNumberOfFiles": "Max number of files exceeded",
    "uploadedBytes": "Uploaded bytes exceed file size",
    "emptyResult": "Empty file upload result"
  };

  return messages[str] || str;
});

Handlebars.registerHelper('createDd', function(item) {
  var result = "";

  if( $.isArray(item) ) {
    $.each(item, function() {
      result += "<dd>" + Handlebars.Utils.escapeExpression(this) + "</dd>";
    });
  } else {
    result = "<dd>" + Handlebars.Utils.escapeExpression(item) + "</dd>";
  }

  return new Handlebars.SafeString(result);
});
