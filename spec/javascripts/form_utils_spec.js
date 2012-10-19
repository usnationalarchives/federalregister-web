describe("form_utils", function() {
  var $li, $input;

  beforeEach(function() {
    $li = $('<li>');
    $li.data('max-size', 10);

    $input = $('<input>').val('1234567');
          
    $li.append( $input );
  });
  
  describe("#chars_remaining", function() {
    it("returns the characters remaining", function() {
      expect( chars_remaining($input) ).toBe(3);
    });
  });

  describe("#add_error", function() {
    beforeEach(function() {
      $li.data('size-warn-at', 5);
    });

    it("returns true when characters remaining are below the warn threshold", function() {
      $input.val('123456');
      expect( add_error($input) ).toBe(true);
    });

    it("returns false when when characters remaining are below the warn threshold", function() {
      $input.val('1234');
      expect( add_error($input) ).toBe(false);
    });
    
    it("returns true when characters remaining are at the warn threshold", function() {
      $input.val('12345');
      expect( add_error($input) ).toBe(true);
    });
  });

  describe("#update_character_count", function() {
    var $error_field;

    beforeEach(function() {
      $error_field = $('<p>').addClass('inline-errors');
      $input.after( $error_field );
      $li.data('size-warn-at', 5);
    });

    it("adds error text when the character count is greater than the warn at size ", function() {
      $input.val('12345678');
      expect( $error_field.text().length ).toBe(0);
      update_character_count( $input );
      expect( $error_field.text().length ).not.toBe(0);
    });

    it("removes error text when the character count is less than the warn at size", function() {
      $input.val('12345678');
      update_character_count( $input );
      expect( $error_field.text().length ).not.toBe(0);

      $input.val('123');
      update_character_count( $input );
      expect( $error_field.text().length ).toBe(0);
    });
  });

  describe("#visually_notify_user", function() {
    var $error_field;

    beforeEach(function() {
      $error_field = $('<p>').addClass('inline-errors');
      $input.after( $error_field );
      $li.data('size-warn-at', 5);
    });

    it("adds an error class to the li wrapper when the characters remaining is less than 0", function() {
      $input.val('1234567891011');
      visually_notify_user($input);
      expect( $li.hasClass('error') ).toBe(true);
    });

    it("removes an error class to the li wrapper when the characters remaining is less than 0", function() {
      $input.val('1234567891011');
      visually_notify_user($input);

      $input.val('1234');
      visually_notify_user($input);
      expect( $li.hasClass('error') ).toBe(false);
    });

    it("adds a warning class to the error field when the characters remaining is greater than 0", function() {
      $input.val('123');
      visually_notify_user($input);
      expect( $error_field.hasClass('warning') ).toBe(true);
    });

    it("removes a warning class to the error field when the characters remaining is less than 0", function() {
      $input.val('123');
      visually_notify_user($input);

      $input.val('1234567891011');
      visually_notify_user($input);
      expect( $error_field.hasClass('warning') ).toBe(false);
    });
  });

  describe("#enforce_characters_remaining", function() {
    it("calls update_character_count with an input", function() {
      spyOn( window, 'update_character_count' );
      enforce_characters_remaining($li);

      expect( update_character_count ).toHaveBeenCalledWith( $li.find('input') );
    });
    
    it("calls visually_notify_user with an input", function() {
      spyOn( window, 'visually_notify_user' );
      enforce_characters_remaining($li);

      expect( visually_notify_user ).toHaveBeenCalledWith( $li.find('input') );
    });
  });

  describe("#validate_field", function() {

    beforeEach(function() {
      $error_field = $('<p>').addClass('inline-errors');
      $input.after( $error_field );

      // setup the error
      $li.addClass('error');
      $error_field.text('Cannot be blank');
      // update the field so that something is in it
      $input.val('123');
    });

    it("removes an error class when there is no longer an error and the input is not blank (eg. the user is correcting an error)", function() {
      spyOn( window, 'add_error').andReturn(false);
      
      validate_field($li);
      expect( $li.hasClass('error') ).toBe(false);
    });

    it("clears the error class when there is no longer an error and the input is not blank (eg. the user is correcting an error)", function() {
      spyOn( window, 'add_error').andReturn(false);
      
      validate_field($li);
      expect( $error_field.text().length ).toBe(0);
    });

    it("does not remove an error class when there is still an error and the input is not blank (eg. the user hasn't corrected an error)", function() {
      spyOn( window, 'add_error').andReturn(true);
      
      validate_field($li);
      expect( $li.hasClass('error') ).toBe(true);
    });

    it("clears the error class when there is no longer an error and the input is not blank (eg. the user hasn't corrected an error)", function() {
      spyOn( window, 'add_error').andReturn(true);
      
      validate_field($li);
      expect( $error_field.text().length ).not.toBe(0);
    });

  });
});
