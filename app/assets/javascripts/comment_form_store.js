var commentFormStorage = {
  storedComment: null,
  form: null,
  documentNumber: null,

  recentlySaved: false,
  saveTimeoutDuration: 5000,
  saveTimeout: null,

  initialize: function(form) {
    var storageInstance = this;

    this.form = $(form);
    this.documentNumber = this.form.data('document-number');
    this.storedComment = amplify.store(this.documentNumber);

    /* add event listeners */
    this.form.delegate(':input', 'keyup change', function(event) {
      if( ! storageInstance.recentlySaved && storageInstance.saveTimeout === null ) {
        storageInstance.recentlySaved = true;
        storageInstance.saveTimeout = setTimeout(function()  {
                                                    storageInstance.storeComment();
                                                    storageInstance.recentlySaved = false;
                                                    storageInstance.saveTimeout = null;
                                                  }, 
                                                  storageInstance.saveTimeoutDuration);
      }
    });

    return storageInstance;
  },

  serializeForm: function() {
    var form_inputs = this.form.find(':input'),
        active_inputs;

    form_inputs = form_inputs
                    .filter(':input[name!=authenticity_token]')
                    .filter(':input[name!=utf8]')
                    .filter(':input[name!="comment[confirm_submission]"]');

    active_inputs = _.filter(form_inputs, function(input) {
      return $(input).val() !== "";
    });

    return $(active_inputs).serialize();
  },

  storeComment: function() {
    this.storedComment = amplify.store(this.documentNumber, this.serializeForm());
  }
};
