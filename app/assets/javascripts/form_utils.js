function update_character_count(input) {
  var $input = $(input),
      $li = $input.closest('li'),
      max_char = $li.data('max-size'),
      warn_char = $li.data('size-warn-at'),
      error_field = $input.siblings('p.inline-errors').first();
      console.log(max_char);

  if( error_field.length === 0 ) {
    $input.after( $('<p>').addClass('inline-errors') );
    error_field = $input.siblings('p.inline-errors').first();
  }

  var remaining = max_char - $input.val().length,
      text = remaining == 1 ? ' character left' : ' characters left';

  if( remaining <= warn_char ) {
    error_field.text( remaining + text );
  } else { 
    error_field.text('');
  }
}

function visually_notify_user(input) {
  var $input = $(input),
      $li = $input.closest('li'),
      max_char = $li.data('max-size'),
      remaining = max_char - $input.val().length,
      error_field = $input.siblings('p.inline-errors').first();

  console.log(remaining, error_field);
  if( remaining < 0 ) {
    $li.addClass('error');
  } else {
    $li.removeClass('error');
  }

  if( remaining >= 0 ) {
    error_field.addClass('warning');
  } else {
    error_field.removeClass('warning');
  }
}

function enfore_characters_remaining(el) {
  var input = $(el).find('input');

  update_character_count(input);
  visually_notify_user(input);
}

function validate_field(el) {
  var $el = $(el),
      $input = $el.find('input');

  $el.removeClass('error');
  $el.find('p.inline-errors').text('');
}
