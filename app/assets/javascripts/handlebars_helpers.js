Handlebars.registerHelper('unlessMyClipboard', function(block) {
  if( this.slug === "my-clippings" ) {
    return block.inverse(this);
  } else {
    return block.fn(this);
  }
});

Handlebars.registerHelper('ifInFolder', function(current_document_number, block) {
  if( this.documents.includes(current_document_number) ) {
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

Handlebars.registerHelper('locale_date', function(date) {
  var inputDate = new Date(date); // Assuming your input date is in YYYY-MM-DD format

  var options = {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  };

  return inputDate.toLocaleDateString('en-US', options);
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

Handlebars.registerHelper('count', function(arr) {
  return arr.length;
});

Handlebars.registerHelper('defaultSubscriptionToDocument', function(val, options) {
  if( val === "Document" ) {
    return options.fn(this);
  }
});

Handlebars.registerHelper('defaultSubscriptionToPIDocument', function(val, options) {
  if( val === "PublicInspectionDocument" ) {
    return options.fn(this);
  }
});

Handlebars.registerHelper('insertLineBreakForNewlines', function(text) {
  text = Handlebars.Utils.escapeExpression(text);
  text = text.replace(/(\r\n|\n|\r)/gm, '<br>');
  return new Handlebars.SafeString(text);
});
