function validate_email(email) {
  var has_error = false,
      error = '',
      email_regex = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;

  if(email == '') {
    has_error = true;
    error = 'blank';
  } else if( !email_regex.test(email) ) {
    has_error = true;
    error = 'invalid'
  }

  return {has_error: has_error, error: error};
}

$(document).ready(function() {
  $('form').on('click', '.email_suggestion .link', function() {
    var $link = $(this);

    $link.closest('li').find('input').val( $link.data('suggestion') );
    $link.closest('.email_suggestion').remove();
  });

  $('form #user_email').on('blur', function() {
    var $input = $(this),
        email_validation = validate_email( $input.val() );

    $input.closest('li').find('span.email_invalid').remove();
    $input.closest('li').find('span.email_suggestion').remove();

    if( email_validation.has_error === false ) {
      $input.closest('form').find('input[type=submit]').enable();

      $input.mailcheck({
        suggested: function(element, suggestion) {
          var template = Handlebars.compile( $("#email-suggestion-template").html() ),
              html = $(template({suggestion: suggestion}));

          element.closest('li').find('span.email_suggestion').remove();
          element.after( html );
        },
        empty: function(element) {
          element.closest('li').find('span.email_suggestion').remove();
        }
      });
    } else {
      var template = Handlebars.compile( $("#email-invalid-template").html() ),
          html = $(template({blank: email_validation.error === 'blank'}));

      $input.after( html );
      $input.closest('form').find('input[type=submit]').disable();
    }
  });

});
