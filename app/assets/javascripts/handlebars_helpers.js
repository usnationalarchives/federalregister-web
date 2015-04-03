function inGroupsOf(count, arr) {
  return _.reduce(arr, function(memo, item) {
    var group = memo[memo.length - 1];

    if( group.length < count ) {
      group.push( item );
    } else {
      memo.push( [item] );
    }

    return memo;
  }, [[]]);
}

Handlebars.registerHelper("debug", function(optionalValue) {
  console.log("Current Context");
  console.log("====================");
  console.log(this);

  if (optionalValue) {
    console.log("Value");
    console.log("====================");
    console.log(optionalValue);
  }
});

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

Handlebars.registerHelper('add_email_to_input', function(email_address) {
  var result = "";

  if( email_address !== "" ) {
   result = "disabled=disabled value=" + email_address;
  }

  return new Handlebars.SafeString(result);
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

Handlebars.registerHelper('pluralize_array', function(arr, single, plural) {
  if( arr.length === 1 ) {
    return single;
  } else {
    return plural;
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

Handlebars.registerHelper('add_email_to_input', function(email_address) {
  var result = "";

  if( email_address !== "" ) {
   result = "disabled=disabled value=" + email_address;
  }

  return new Handlebars.SafeString(result);
});

Handlebars.registerHelper('count', function(arr) {
  return arr.length;
});

Handlebars.registerHelper('inColumns', function(arr, options) {
  var inEachColumn, perColumnCount, result, count;

  count = options.hash['count'];

  inEachColumn =  Math.floor(arr.length / count);

  if( arr.length % count === 0 ) {
    perColumnCount = inEachColumn;
  } else {
    perColumnCount = inEachColumn + 1;
  }

  result = inGroupsOf(perColumnCount, arr);
  result = _.flatten(_.zip.apply(_, result));

  return options.fn(result);
});
