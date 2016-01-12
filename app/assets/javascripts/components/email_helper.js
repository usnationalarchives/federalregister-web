var EmailHelper = (function() {
  var EmailHelper = function() {
    this.input = null;
    this.initialized = false;
  };

  EmailHelper.prototype = {
    initialize: function(input) {
      this.input = $(input);
      this.initialized = true;
    },

    reset_help_text: function() {
      this.input.closest('li').find('span.email_invalid').remove();
      this.input.closest('li').find('span.email_suggestion').remove();
    },

    validate_or_suggest: function() {
      this.reset_help_text();

      var email_validator = this.validate_email();

      if( email_validator.has_error === false ) {
        this.enable_form();
        this.display_or_remove_suggestion();
      } else {
        this.display_error(email_validator);
        this.disable_form();
      }
    },

    validate_email: function() {
      var email = this.input.val(),
          has_error = false,
          error = '',
          email_regex = /^([\w\.%\+'\-]+)@([\w\-]+\.)+([\w]{2,})$/;

      if(email === '') {
        has_error = true;
        error = 'blank';
      } else if( !email_regex.test(email) ) {
        has_error = true;
        error = 'invalid';
      }

      return {has_error: has_error, error: error};
    },

    display_or_remove_suggestion: function() {
      this.input.mailcheck({
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
    },

    display_error: function(email_validator) {
      var template = Handlebars.compile( $("#email-invalid-template").html() ),
            html = $(template({blank: email_validator.error === 'blank'}));

      this.input.after( html );
    },

    use_suggestion: function(link) {
      link.closest('li').find('input').val( link.data('suggestion') );
      link.closest('.email_suggestion').remove();
    },

    enable_form: function() {
      var $submit = this.input.closest('form').find('input[type=submit]');

      $submit.prop('disabled', false);
      $submit.removeClass('disabled');
      $submit.closest('li').removeClass('disabled');
    },

    disable_form: function() {
      var $submit = this.input.closest('form').find('input[type=submit]');

      $submit.prop('disabled', true);
      $submit.addClass('disabled');
      $submit.closest('li').addClass('disabled');
    }
  };

  return EmailHelper;
})();
