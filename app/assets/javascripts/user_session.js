$(document).ready(function() {
  var email_helper = new EmailHelper();

  $('form').on('click', '.email_suggestion .link', function() {
    email_helper.use_suggestion( $(this) );
  });

  $('form#new_user').on('blur', '#user_email', function() {
    var $input = $(this);

    if( !email_helper.initialized ) {
      email_helper.initialize($input);
    }

    email_helper.validate_or_suggest();
  });

  $('form#password_reset').on('input onpropertychange', '#user_email', function() {
    var $input = $(this);

    clearTimeout($input.data('timeout'));

    if( !email_helper.initialized ) {
      email_helper.initialize($input);
    }

    email_helper.reset_help_text();

    $input.data('timeout', setTimeout(function(){
      email_helper.validate_or_suggest();
    }, 500));
  });
});
