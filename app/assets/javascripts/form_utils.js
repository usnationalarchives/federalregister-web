function chars_remaining(input) {
  var $input = $(input),
      $li = $input.closest('li'),
      max_char = $li.data('max-size');

  return max_char - $input.val().length;
}

function add_error(input) {
  var  $input = $(input),
       $li = $input.closest('li'),
       warn_threshold = $li.data('size-warn-at');

  return chars_remaining(input) <= warn_threshold;
}

function update_character_count(input) {
  var $input = $(input),
      $li = $input.closest('li'),
      error_field = $input.siblings('p.inline-errors').first();

  if( error_field.length === 0 ) {
    $input.after( $('<p>').addClass('inline-errors') );
    error_field = $input.siblings('p.inline-errors').first();
  }

  var remaining = chars_remaining($input),
      text = remaining == 1 ? ' character left' : ' characters left';

  if( add_error($input) ) {
    error_field.text( remaining + text );
  } else { 
    error_field.text('');
  }
}

function visually_notify_user(input) {
  var $input = $(input),
      $li = $input.closest('li'),
      remaining = chars_remaining($input),
      error_field = $input.siblings('p.inline-errors').first();

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

function enforce_characters_remaining(el) {
  var input = $(el).find('input');

  update_character_count(input);
  visually_notify_user(input);
}

function validate_field(el) {
  var $el = $(el),
      $input = $el.find('input');

  if( $input !== undefined ) {
    if( !add_error($input) && $input.val().length > 0 ) {
      $el.removeClass('error');
      $el.find('p.inline-errors').text('');
    }
  }
}
