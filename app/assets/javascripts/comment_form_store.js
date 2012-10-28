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
    return this.form.find(':input[name!=authenticity_token]').serialize();
  },

  storeComment: function() {
    this.storedComment = amplify.store(this.documentNumber, this.serializeForm());
  }
};
